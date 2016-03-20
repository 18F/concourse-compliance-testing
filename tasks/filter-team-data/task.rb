require 'json'
require_relative 'team_data_filterer'

PROJECT_JSON = ENV['PROJECT_JSON'] || File.expand_path('../../../../projects-json/projects.json', __FILE__)
TARGETS = File.expand_path('../../../targets.json', __FILE__)
RESULTS = ENV['RESULTS'] || File.expand_path('../../../../results/projects.json', __FILE__)

projects = JSON.load(File.new(PROJECT_JSON))
targets = JSON.load(File.new(TARGETS))

filtered_projects = TeamDataFilterer.filtered_projects(projects, targets)

JSON.dump(filtered_projects, File.new(RESULTS, 'w'))

puts "TASK COMPLETE"
