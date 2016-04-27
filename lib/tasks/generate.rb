Dir.glob(Rakuda.root.join("lib").join("generate").join("*.rb")).each do |file|
  require file
end

FileUtils.rm_rf Rakuda.im_path
FileUtils.mkdir_p Rakuda.im_path

puts "[start generate]=============#{Time.now}"
puts "出力先: #{Rakuda.im_path}"

Generates.models.each do |model|
  gen_code = "
  class #{model.name} < ActiveRecord::Base
    after_initialize :readonly!
    include GeneralAttributes
    def self.after_name
      '#{(model.after_name || model.name).underscore}'
    end
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
    gen_code += "alias_attribute :#{k}, :#{v}
    "
  end

  (model.modules || []).each do |mdl| 
    gen_code += "include #{mdl}
    "
  end

  gen_code += "
    def convert
      {"
  (model.attributes || []).each_with_index do |k, i| 
    if i == 0
      gen_code += "\n        '#{k}' => self.#{k}"
    else
      gen_code += ",\n        '#{k}' => self.#{k}"
    end
  end

  gen_code += "
      }.reject{|key, value| (value.nil? || value == '')}
    end
  end
  "
  puts gen_code if Settings.debug
  eval gen_code
  model.name.constantize.establish_connection Rakuda.dbconfig[model.db]
  model.name.constantize.table_name = model.table unless model.table.nil?
  model.name.constantize.primary_key = model.id.to_sym unless model.id.nil?
  model.name.constantize.inheritance_column = nil if model.inheritance
end

finally = []

Generates.models.each do |model|
  print "#{model.name} の処理を開始します".ljust(40, ".")
  puts "総件数 #{model.name.constantize.count}"
  #next if exec_model_name.present? and model.name != exec_model_name
  Rakuda.models[model.name.constantize.after_name] ||= []
  records = if Generates.limit > 0
              model.name.constantize.limit(Generates.limit)
            else
              model.name.constantize.all
            end
  threads = Settings.threads
  threads = Parallel.processor_count if threads == 0
  Parallel.each_with_index(records, in_threads: Settings.threads) do | object, idx |
    object.id = idx + (model.auto_numbering_begin || 1).to_i if model.auto_numbering
    value = object.convert
    valid = true
    encoding = Rakuda.dbconfig[model.db]["encoding"] || "utf8"
    unless encoding == "utf8"
      require "nkf"
      opt = case encoding
            when "ujis"
              '-E -w'
            when "sjis"
              '-S -w'
            when "jis"
              '-J -w'
            else
              '-E -w'
            end
      value.each do |k, v|
        if v.nil? || v.blank? || k == "creater" || k == "updater"
          next
        elsif (model.keep_encodes || []).include?(k)
          #puts k
          #puts model.keep_encodes
          next
        elsif v.is_a?(String)
          value[k] = NKF.nkf opt, v
        else
          puts "#{k} is not a String" if Settings.debug
        end
      end
    end
    (model.required || []).each do | col |
      valid = false if value[col].nil?
    end
    if valid
      Rakuda.models[model.name.constantize.after_name].push value
    else
      puts "バリデーションのエラーが発生しました#{value}"
    end
  end

  Rakuda.models[model.name.constantize.after_name].keep_if{|item| item.length != 0}

  model_name = model.name.constantize.after_name
  if model.data_output_finally == true
    finally.push model_name
    next
  end
  case Settings.output_type
  when "yaml"
    File.open(Rakuda.im_path.join(model_name), 'w') do | file |
      file << YAML.dump(Rakuda.models[model_name])
    end
  when "json"
    require 'json'
    File.open(Rakuda.im_path.join(model_name), 'w') do | file |
      file << Rakuda.models[model_name].to_json
    end
  else
    puts "エラー：出力形式「#{Settings.output_type}」には対応していません。"
  end
  Rakuda.models[model_name] = nil unless model.keep_mem_data == true
end

finally.each do |model_name|
  case Settings.output_type
  when "yaml"
    File.open(Rakuda.im_path.join(model_name), 'w') do | file |
      file << YAML.dump(Rakuda.models[model_name])
    end
  when "json"
    require 'json'
    File.open(Rakuda.im_path.join(model_name), 'w') do | file |
      file << Rakuda.models[model_name].to_json
    end
  else
    puts "エラー：出力形式「#{Settings.output_type}」には対応していません。"
  end
end

puts "[finish generate]=============#{Time.now}"

