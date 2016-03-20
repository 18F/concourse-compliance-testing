require 'json'
require_relative 'team_data_filterer'

PROJECT_JSON = ENV['PROJECT_JSON'] || File.expand_path('../../../../projects-json/projects.json', __FILE__)
TARGETS = File.expand_path('../../../targets.json', __FILE__)
RESULTS = ENV['RESULTS'] || File.expand_path('../../../../results/projects.json', __FILE__)

projects = TeamDataFilterer.read_json(PROJECT_JSON)['results']
targets = TeamDataFilterer.read_json(TARGETS)

filtered_projects = TeamDataFilterer.filtered_projects(projects, targets)
TeamDataFilterer.write_json(filtered_projects, RESULTS)

puts "TASK COMPLETE"
