require 'rake/testtask'

# Ruby tests
Rake::TestTask.new do |t|
  t.pattern = '**/test_*.rb'
end

# Javascript tests
Rake::TestTask.new do
  puts `cd tasks/uptime-check && mocha`
end

task default: :test
