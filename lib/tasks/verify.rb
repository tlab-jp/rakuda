Dir.glob(Rakuda.root.join("lib").join("verify").join("*.rb")).each do |file|
  require file
end
require 'csv'

FileUtils.rm_rf Rakuda.verify_path
FileUtils.mkdir_p Rakuda.verify_path
FileUtils.mkdir_p Rakuda.verify_path.join("before")
FileUtils.mkdir_p Rakuda.verify_path.join("after")

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
    scope = scope.where("id >= ?",model.after.start_id) if model.after.start_id.to_i > 0
    scope = scope.where(model.after.scope) unless model.after.scope.nil?
    scope.each do |klass|
      file << klass.output_verify
    end
  end
  CSV.open(Rakuda.verify_path.join("before").join(model.name), 'w') do | file |
    scope = "#{model.name}Before".constantize.all
    scope = scope.where("id >= ?",model.before.start_id) if model.before.start_id.to_i > 0
    scope = scope.where(model.before.scope) unless model.before.scope.nil?
    scope.each do |klass|
      file << klass.output_verify
    end
  end
  puts "完了"
end

puts "[finish verify(file create)]=============#{Time.now}"

