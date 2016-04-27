class Settings < Settingslogic
  source Rakuda.root.join("config").join("rakuda.yml")
  namespace Rakuda.env
  suppress_errors true
end
