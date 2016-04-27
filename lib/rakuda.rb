class Rakuda
  @@root = nil
  @@dbconfig = nil
  def self.root
    @@root ||= Pathname.new(File.expand_path('../../', __FILE__))
  end

  def self.im_path
    @@im_path ||= (ENV["RAKUDA_IM_PATH"] || Rakuda.root.join("dist").join("intermediate_files"))
  end

  def self.verify_path
    @@verify_path ||= (ENV["RAKUDA_VF_PATH"] || Rakuda.root.join("dist").join("verify"))
  end

  def self.dbconfig
    return @@dbconfig unless @@dbconfig.nil?
    @@dbconfig = YAML.load(
      File.read(
        self.root.join("config").join("database.yml")
      )
    )
    @@dbconfig.each do |k, v|
      next unless v["adapter"] == "sqlite3"
      @@dbconfig[k]["database"] = self.root.join(v["database"]).to_s
    end
    @@dbconfig
  end

  def self.logger
    @@logger ||= Logger.new(self.root.join("log").join("application.log"))
  end

  def self.env
    @@env ||= ENV['RAKUDA_ENV'] || "production"
  end

  def self.models
    @@models ||= {}
  end
end
