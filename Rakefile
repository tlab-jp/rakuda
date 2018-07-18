require_relative "config/application"
require 'bundler/setup'
require 'active_record'
require 'erb'
require 'yaml'
require 'logger'

Rails = Rakuda

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
  desc "Migrate database (require: RAKUDA_ENV, optional: VERSION)"
  task migrate: :dbenv do
    ActiveRecord::Tasks::DatabaseTasks.migrate
  end

  desc "Reset database (require: RAKUDA_ENV)"
  task reset: ["db:drop", "db:create", "db:migrate"]

  desc "Create database (require: RAKUDA_ENV)"
  task create: [:dbenv, :check_safety] do
    ActiveRecord::Tasks::DatabaseTasks.create_current
  end

  desc "Drop database (require: RAKUDA_ENV)"
  task drop: [:dbenv, :check_safety] do
    ActiveRecord::Tasks::DatabaseTasks.drop_current
  end

  desc "Insert seeds to database (require: RAKUDA_ENV)"
  task seed: :dbenv do
    seeds_path = Rakuda.root.join("db", "seeds", "#{ENV["RAKUDA_ENV"]}.sql")
    IO.foreach(seeds_path) do |row|
      ActiveRecord::Base.connection.execute row
    end
  end
end

task :dbenv do
  if ENV["RAKUDA_ENV"].nil?
    puts "Require RAKUDA_ENV env option"
    exit 2
  end
  ENV["RAILS_ENV"] = Rakuda.env
  ActiveRecord::Tasks::DatabaseTasks.database_configuration = Rakuda.dbconfig
  ActiveRecord::Base.configurations = ActiveRecord::Tasks::DatabaseTasks.database_configuration
  ActiveRecord::Migrator.migrations_paths = Rakuda.root.join("db", "migrate", ENV["RAKUDA_ENV"])
  ActiveRecord::Base.establish_connection Rakuda.dbconfig[ENV["RAKUDA_DB"]]
end

task :check_safety do
  #ActiveRecord::Tasks::DatabaseTasks.check_protected_environments!
end
