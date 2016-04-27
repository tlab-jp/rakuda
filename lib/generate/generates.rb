class Generates < Settingslogic
  source Rakuda.root.join("config").join("generate.yml")
  namespace Rakuda.env
  suppress_errors true
end
