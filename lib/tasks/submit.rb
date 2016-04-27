Dir.glob(Rakuda.root.join("lib").join("submit").join("*.rb")).each do |file|
  require file
end

unless Dir.exists?(Rakuda.im_path)
  puts "中間ファイルパスが存在しません"
  puts "中間ファイルパス: #{Rakuda.im_path}"
  exit 2
end

puts "[submit start]=============#{Time.now}"
puts "Data file path: #{Rakuda.im_path}/<files>"

Submits.models.each do |model|
  gen_code = "
  class #{model.name} < ActiveRecord::Base
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
  model.name.constantize.establish_connection Rakuda.dbconfig[model.db]
  model.name.constantize.table_name = model.table unless model.table.nil?
  model.name.constantize.primary_key = model.id.to_sym unless model.id.nil?
end


Submits.models.each do |model|
  classname = model.name
  data_path = Rakuda.im_path.join(classname.underscore)
  unless File.exists?(data_path)
    puts "Loaded: #{data_path}"
    puts "#{classname}はデータがないためスキップします"
    next
  end
  value = YAML.load(File.read(data_path))
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

  if Submits.force_reset
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
    puts classname.constantize.count == 0 ? "成功" : "失敗"
  end

  print "Migrate #{classname.constantize.to_s}#{"s" if value.count > 1} ..."
  # TODO: update 対象判別、更新後の全件数を既存と新規及びアップデート件数より算出
  # TODO: update 機能作成
  value.each do | hash |
    $hash = hash
    begin
      classname.constantize.create hash
    rescue => ex
      puts "#{classname}の作成に失敗しました。#{hash} (#{ex.message})"
    end
  end

  totalcount = classname.constantize.count
  createcount = totalcount - classcount
  if createcount == value.count
    puts " OK (succeed: #{createcount}/failed: 0/ total: #{totalcount})"
  else
    puts " NG (succeed: #{createcount}/failed: #{value.count - createcount}/ total: #{totalcount})"
  end
  value = nil
end

puts "[submit finish]=============#{Time.now}"
