# Functions related to a ZAP Project
class ZAPProject
  attr_reader :name, :path

  def initialize(name, path)
    @name = name
    @path = path
  end

  def project_path
    "#{path}/#{name}.json"
  end

  def source_exists?
    File.exist?(project_path)
  end
end
