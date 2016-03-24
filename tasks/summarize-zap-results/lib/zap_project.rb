# Functions related to a ZAP Project
module ZAPProject
  class << self
    def count(results_dir)
      json_files_from_dir(results_dir).size
    end

    def names(results_dir)
      json_files_from_dir(results_dir).map { |file| project_name_from_file(file) }
    end

    def project_path(project, path)
      "#{path}/#{project}.json"
    end

    def missing_project_json?(proj, results_dir)
      !File.exist?(project_path(proj, results_dir))
    end

    private

    def json_files_from_dir(path)
      Dir["#{path}/*.json"]
    end

    def project_name_from_file(path)
      File.basename(path, ".json")
    end
  end
end
