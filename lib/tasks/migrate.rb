Dir.glob(Rakuda.root.join("lib").join("migrate").join("*.rb")).each do |file|
  require file
end

if Migrates.models.nil?
  puts "migration setting is not define"
  exit 2
end
puts "[start migrate]=============#{Time.now}"
Migrates.models.each do |migration|
  classname = migration.name
  classname_before = "#{classname}Before"
  model = migration.before
  gen_code = "
    class #{classname_before} < ActiveRecord::Base
      after_initialize :readonly!
      include GeneralAttributes
      #{"attr_accessor :id" if !model.id.nil? && model.auto_numbering}
  "
  (model.associations || []).each do |asc| 
    next unless asc.method
    next unless asc.scope
    gen_code += "#{asc.method} :#{asc.scope}#{", #{asc.options}" unless asc.options.nil?}
    "
  end

  (model.aliases || {}).each do |k, v|
    next unless k
    next unless v
    gen_code += "alias_attribute :#{v}, :#{k}
    "
  end

  (model.modules || []).each do |mdl| 
    gen_code += "include #{mdl}
    end
    "
  end

  puts gen_code if Settings.debug
  eval gen_code
  classname_before.constantize.establish_connection Rakuda.dbconfig[model.db]
  classname_before.constantize.table_name = model.table unless model.table.nil?
  classname_before.constantize.primary_key = model.id.to_sym unless model.id.nil?
  classname_before.constantize.inheritance_column = nil if model.inheritance

  model = migration.after
  gen_code = "
  class #{classname} < ActiveRecord::Base
    "

  (model.associations || []).each do |asc|
    next unless asc.method
    next unless asc.scope
    gen_code += "#{asc.method} :#{asc.scope}#{", #{asc.options}" unless asc.options.nil?}
    "
  end

  (model.attrs || []).each do |attr| 
    next unless attr.method
    next unless attr.scope
    gen_code += "#{attr.method} :#{attr.scope}#{", #{attr.options}" unless attr.options.nil?}
    "
  end

  (model.modules || []).each do |mdl|
    gen_code += "include #{mdl}
    "
  end

  gen_code += "
  end
  "

  puts gen_code if Settings.debug
  eval gen_code
  classname.constantize.establish_connection Rakuda.dbconfig[model.db]
  classname.constantize.table_name = model.table unless model.table.nil?
  classname.constantize.primary_key = model.id.to_sym unless model.id.nil?
end

Migrates.models.each do |migration|
  classname = migration.name
  classname_before = "#{classname}Before"
  model = migration.after

  classcount = 0
  print "Checking #{classname} ... "
  begin
    classcount = classname.constantize.count
    puts "成功 (既存データ#{classcount}件)"
  rescue
    puts "失敗"
    puts "クラスが存在しません"
    next
  end

  if Migrates.force_reset
    print "Delete All #{classname}s ... "
    tablename = model.table || classname.tableize
    ActiveRecord::Base.establish_connection Rakuda.dbconfig[model.db]
    case Rakuda.dbconfig[model.db]["adapter"]
    when "sqlite3"
      ActiveRecord::Base.connection.execute("DELETE FROM #{tablename}")
      ActiveRecord::Base.connection.execute("DELETE FROM sqlite_sequence WHERE name='#{tablename}';")
      ActiveRecord::Base.connection.execute("VACUUM")
    else
      ActiveRecord::Base.connection.execute("TRUNCATE #{tablename}")
    end
    if classname.constantize.count == 0
      classcount = 0
      puts "成功"
    else
      puts "失敗"
    end
  end

  scope = classname_before.constantize.all
  data_count = scope.count
  print "Migrate #{classname.constantize.to_s}#{"s" if data_count > 1}(#{data_count}) ..."
  scope.each do | data |
    obj = classname.constantize.new
    if migration.auto_matching
      classname.constantize.attribute_names.each do |key|
        obj.send("#{key}=", data.send(key)) if data.attribute_names.include?(key)
      end
    end
    (migration.attributes || {}).each do |key1, key2|
      obj.send("#{key2}=", data.send(key1))
    end
    begin
      unless obj.save
        puts "#{classname}の作成に失敗しました。#{obj.errors.full_messages}"
      end
    rescue => ex
      puts "#{classname}の作成に失敗しました。#{hash} (#{ex.message})"
    end
  end

  totalcount = classname.constantize.count
  createcount = totalcount - classcount
  if createcount == data_count
    puts " OK (succeed: #{createcount}/failed: 0/ total: #{totalcount})"
  else
    puts " NG (succeed: #{createcount}/failed: #{data_count - createcount}/ total: #{totalcount})"
  end
  value = nil
end

puts "[finish migrate]=============#{Time.now}"
