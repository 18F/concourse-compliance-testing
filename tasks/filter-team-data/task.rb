require 'json'
require 'set'

PROJECT_JSON = ENV['PROJECT_JSON'] || File.expand_path('../../../../projects-json/projects.json', __FILE__)
TARGETS = File.expand_path('../../../targets.json', __FILE__)
RESULTS = ENV['RESULTS'] || File.expand_path('../../../../results/projects.json', __FILE__)

projects = JSON.load(File.new(PROJECT_JSON))
targets = JSON.load(File.new(TARGETS))

projects_by_name = {}
projects['results'].each do |project|
  name = project['name']
  projects_by_name[name] = project
end

filtered_projects = []
targets.each do |target|
  name = target['name']
  project = projects_by_name[name]
  if project
    # copy in overridden attributes from the targets.json
    filtered_project = project.merge(target)
    filtered_projects << filtered_project
  else
    STDERR.puts "WARN: `#{name}` is missing from Team API data."
  end
end

JSON.dump(filtered_projects, File.new(RESULTS, 'w'))

puts "TASK COMPLETE"
