require 'json'

# helper methods for filter-team-data
module TeamDataFilterer
  class << self
    def transform_links(links)
      links.map do |link|
        case link
        # the new about.yml format
        # https://github.com/18F/about_yml#aboutyml-cheat-sheet
        when Hash
          link
        # the old about.yml format
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

      result['name'] = result['name'].downcase

      # not always present in about.yml
      links = result['links'] || []
      result['links'] = transform_links(links)

      result
    end

    def filtered_projects(projects, targets)
      p_by_name = projects_by_name(projects)

      targets.map do |target|
        build_target(target, p_by_name)
      end
    end

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

    def target(project_name)
      targets.find { |t| t['name'] == project_name }
    end

    private

    def projects_by_name(projects)
      results = {}
      projects.each do |project|
        name = project['name'].downcase
        results[name] = project
      end
      results
    end

    def build_target(target, p_by_name)
      name = target['name'].downcase
      project = p_by_name[name]

      unless project
        STDERR.puts "WARN: `#{name}` is missing from Team API data."
        project = {}
      end

      transform_project(project, target)
    end
  end
end
