require_relative "config/application"
require 'bundler/setup'
require 'active_record'
require 'erb'
require 'yaml'
require 'logger'

task default: :usage

task :usage do
  system "bundle exec rake -sT"
end

namespace :data do
  desc "Generate intermediate files."
  task :generate do
    require Rakuda.root.join("lib").join("tasks").join("generate")
  end
  desc "To register the data from the intermediate files."
  task :submit do
    require Rakuda.root.join("lib").join("tasks").join("submit")
  end
  desc "Data migrate(copy) before_db to after_db (direct)."
  task :migrate do
    require Rakuda.root.join("lib").join("tasks").join("migrate")
  end
  desc "Create csv file that before data and after data for verify."
  task :verify do
    require Rakuda.root.join("lib").join("tasks").join("verify")
  end
end

namespace :db do
  desc "Migrate database (require: RAKUDA_DB, optional: VERSION)"
  task migrate: :dbenv do
    ActiveRecord::Migrator.migrate(Rakuda.root.join("db", "migrate", ENV["RAKUDA_DB"]), ENV["VERSION"] ? ENV["VERSION"].to_i : nil )
  end

  desc "Reset database (require: RAKUDA_DB)"
  task reset: :dbenv do
    ActiveRecord::Migrator.migrate(Rakuda.root.join("db", "migrate", ENV["RAKUDA_DB"]), 0 )
    ActiveRecord::Migrator.migrate(Rakuda.root.join("db", "migrate", ENV["RAKUDA_DB"]), nil )
  end

  desc "Insert seeds to database (require: RAKUDA_DB)"
  task seed: :dbenv do
    seeds_path = Rakuda.root.join("db", "seeds", "#{ENV["RAKUDA_DB"]}.yml")
    IO.foreach(seeds_path) do |row|
      ActiveRecord::Base.connection.execute row
    end
  end
end

task :dbenv do
  if ENV["RAKUDA_DB"].nil?
    puts "Require RAKUDA_DB env option"
    exit 2
  end
  ActiveRecord::Base.establish_connection Rakuda.dbconfig[ENV["RAKUDA_DB"]]
end
