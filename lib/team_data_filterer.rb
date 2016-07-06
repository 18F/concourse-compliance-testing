require 'json'
require 'uri'

module TeamDataFilterer
  class << self
    def read_json(path)
      JSON.load(File.new(path))
    end

    def write_json(data, path)
      JSON.dump(data, File.new(path, 'w'))
    end

    def targets
      path = File.expand_path('../../config/targets.json', __FILE__)
      read_json(path)
    end
  end
end
