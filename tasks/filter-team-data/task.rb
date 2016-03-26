require_relative 'team_data_filterer'

PROJECT_JSON = ENV['PROJECT_JSON'] || File.expand_path('../../../../projects-json/projects.json', __FILE__)
RESULTS = ENV['RESULTS'] || File.expand_path('../../../../filtered-projects/projects.json', __FILE__)

projects = TeamDataFilterer.read_json(PROJECT_JSON)['results']
targets = TeamDataFilterer.targets

filtered_projects = TeamDataFilterer.filtered_projects(projects, targets)
TeamDataFilterer.write_json(filtered_projects, RESULTS)

puts "TASK COMPLETE"
