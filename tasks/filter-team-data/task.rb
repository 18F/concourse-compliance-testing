require 'json'

PROJECT_JSON = File.expand_path('../../../../projects-json/projects.json', __FILE__)

contents = File.read(PROJECT_JSON)
data = JSON.parse(contents)
puts data.inspect
