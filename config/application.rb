# coding: utf-8


require File.expand_path('../../lib/rakuda', __FILE__)
require Rakuda.root.join("config").join("boot")
require Rakuda.root.join("config").join("boot_environment")
require 'rubygems'
require 'bundler/setup'
require 'parallel'
require 'active_record'
require 'attr_encrypted'
require 'logger'
require 'yaml'
require 'settingslogic'

ActiveRecord::Base.establish_connection(Rakuda.dbconfig.values.first)

Dir.glob(Rakuda.root.join("config").join("initializers").join("*.rb")).each do |rb|
  require rb
end

Dir.glob(Rakuda.root.join("lib").join("share").join("*.rb")).each do |file|
  require file
end

ActiveRecord::Base.logger = Logger.new(Rakuda.root.join("log").join("active_record.log"))
ActiveRecord::Base.logger.formatter = Logger::RakudaFormat.new
ActiveRecord::Base.logger.level = 0
Rakuda.logger.formatter = Logger::RakudaFormat.new

