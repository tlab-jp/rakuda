class Submits < Settingslogic
  source Rakuda.root.join("config").join("submit.yml")
  namespace Rakuda.env
  suppress_errors true
end
