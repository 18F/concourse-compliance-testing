require_relative '../../lib/team_data_filterer'

PROJECT_JSON = ENV['PROJECT_JSON'] || File.expand_path('../../../../project-data/project.json', __FILE__)
RESULTS = ENV['RESULTS'] || File.expand_path('../../../../filtered-project-data/project.json', __FILE__)

project = TeamDataFilterer.read_json(PROJECT_JSON)
target = TeamDataFilterer.target(project['name'].downcase) || {}

filtered_project = TeamDataFilterer.transform_project(project, target)
TeamDataFilterer.write_json(filtered_project, RESULTS)

puts "TASK COMPLETE"
