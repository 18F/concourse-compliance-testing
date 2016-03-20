module TeamDataFilterer
  class << self
    def projects_by_name(projects)
      results = {}
      projects.each do |project|
        name = project['name']
        results[name] = project
      end
      results
    end

    # copy in overridden attributes from the target
    def transform_project(project, target)
      project.merge(target)
    end

    def filtered_projects(projects, targets)
      p_by_name = self.projects_by_name(projects)

      results = []
      targets.each do |target|
        name = target['name']
        project = p_by_name[name]
        if project
          results << transform_project(project, target)
        else
          STDERR.puts "WARN: `#{name}` is missing from Team API data."
        end
      end

      results
    end

    def read_json(path)
      JSON.load(File.new(path))
    end

    def write_json(data, path)
      JSON.dump(data, File.new(path, 'w'))
    end
  end
end
