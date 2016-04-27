class Migrates < Settingslogic
  source Rakuda.root.join("config").join("migrate.yml")
  namespace Rakuda.env
  suppress_errors true
end
