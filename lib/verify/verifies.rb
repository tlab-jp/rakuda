class Verifies < Settingslogic
  source Rakuda.root.join("config").join("verify.yml")
  namespace Rakuda.env
  suppress_errors true
end
