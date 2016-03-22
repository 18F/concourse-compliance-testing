require 'json'

# Functions to access a project's zap results
module ZAPResult
  # A single Project/Result
  Result = Struct.new(:name, :confidence, :risk, :url, :param, :evidence, :alert)
  class << self
    def project_results(proj, path)
      json = read_json(project_path(proj, path))
      json_to_results(proj, json)
    end

    def json_files_from_dir(path)
      Dir["#{path}/*.json"]
    end

    # Previous or Current json files could be missing. It's useful to think
    #  of a missing file producing an empty Result set, i.e. `[]` below.
    def read_json(path)
      File.exist?(path) ? JSON.parse(File.read(path)) : []
    end

    def missing_project_json?(proj, dir)
      read_json(project_path(proj, dir)).empty?
    end

    def json_to_results(project_name, json_results)
      json_results.map do |jr|
        Result.new(project_name, jr['confidence'], jr['risk'], jr['url'],
          jr['param'], jr['evidence'], jr['alert']) unless js_or_css?(jr['url'])
      end.compact
    end

    def project_path(project, path)
      "#{path}/#{project}.json"
    end

    def project_name_from_path(path)
      File.basename(path, ".json")
    end

    def projects_count(run_dir)
      json_files_from_dir(run_dir).size
    end

    def all_project_names(last_path, curr_path)
      all_files = json_files_from_dir(last_path) + json_files_from_dir(curr_path)
      all_names = all_files.map{ |file| project_name_from_path(file) }
      all_names.uniq
    end

    def js_or_css?(url)
      url.match(/.js|.css/)
    end
  end
end
