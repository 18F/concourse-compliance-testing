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

    def transform_links(links)
      links.map do |link|
        case link
        when Hash
          link
        when String
          { "url" => link }
        else
          STDERR.puts "WARN: unknown link format: `#{link.inspect}`."
        end
      end
    end

    # copy in overridden attributes from the target
    def transform_project(project, target)
      result = project.merge(target)

      links = result['links'] || []
      result['links'] = self.transform_links(links)

      result
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
