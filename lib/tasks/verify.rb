Dir.glob(Rakuda.root.join("lib").join("verify").join("*.rb")).each do |file|
  require file
end
require 'csv'

FileUtils.rm_rf Rakuda.verify_path
FileUtils.mkdir_p Rakuda.verify_path
FileUtils.mkdir_p Rakuda.verify_path.join("before")
FileUtils.mkdir_p Rakuda.verify_path.join("after")

if Verifies.models.nil?
  puts "verify setting is not define"
  exit 2
end
puts "[start verify(file create)]=============#{Time.now}"
puts "出力先: #{Rakuda.verify_path}"

Verifies.models.each do |model|
  {after: model.after, before: model.before}.each do |key, value|
    key = key.to_s
    model_name = model.name + (key == "after" ? "After" : "Before")
    gen_code = "
      class #{model_name} < ActiveRecord::Base
        after_initialize :readonly!
    "

    (value.associations || []).each do |asc|
      next unless asc.method
      next unless asc.scope
      gen_code += "#{asc.method} :#{asc.scope}#{", #{asc.options}" unless asc.options.nil?}
      "
    end

    (value.modules || []).each do |mdl| 
      gen_code += "include #{mdl}
      "
    end

    gen_code += "
      def output_verify
        ["
    flg=true
    (model.attributes || {}).each do |k, v| 
      method_name = (key == "after" ? v : k)
      if flg == true
        flg = false
      else
        gen_code += ","
      end
      gen_code += "\n          self.#{method_name}"
    end

    gen_code += "
        ].map{|ittr| ittr.blank? ? nil : ittr}
      end
    end
    "
    puts gen_code if Settings.debug
    eval gen_code
    model_name.constantize.establish_connection Rakuda.dbconfig[value.db]
    table_name = value.table.nil? ? model.name.tableize : value.table
    model_name.constantize.table_name = table_name
    model_name.constantize.primary_key = value.id.to_sym unless value.id.nil?
    model_name.constantize.inheritance_column = nil if value.inheritance
  end
end

Verifies.models.each do |model|
  print "#{model.name} の処理を開始します"
  CSV.open(Rakuda.verify_path.join("after").join(model.name), 'w') do | file |
    scope = "#{model.name}After".constantize.all
    unless model.after.scope.nil?
      (model.after.scope.joins || []).each do |join|
        scope = scope.joins(join.to_sym)
      end
      (model.after.scope.wheres || []).each do |where|
        scope = scope.where(where)
      end
      (model.after.scope.orders || []).each do |order|
        scope = scope.order(order)
      end
    end
    scope.each do |klass|
      file << klass.output_verify
    end
  end
  CSV.open(Rakuda.verify_path.join("before").join(model.name), 'w') do | file |
    scope = "#{model.name}Before".constantize.all
    unless model.before.scope.nil?
      (model.before.scope.joins || []).each do |join|
        scope = scope.joins(join.to_sym)
      end
      (model.before.scope.wheres || []).each do |where|
        scope = scope.where(where)
      end
      (model.before.scope.orders || []).each do |order|
        scope = scope.order(order)
      end
    end
    scope.each do |klass|
      file << klass.output_verify
    end
  end
  puts "完了"
end

puts "[finish verify(file create)]=============#{Time.now}"

