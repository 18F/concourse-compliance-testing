# Functions related to a ZAP Project
module ZAPProject
  class << self
    def project_path(project, path)
      "#{path}/#{project}.json"
    end

    def missing_project_json?(proj, results_dir)
      !File.exist?(project_path(proj, results_dir))
    end
  end
end
