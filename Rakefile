require 'rake/testtask'

# Ruby tests
Rake::TestTask.new do |t|
  t.pattern = '**/test_*.rb'
end

desc "Run JavaScript tests"
task :js_tests do
  Dir.chdir('tasks/uptime-check') do
    sh 'mocha'
  end
end

task default: [:test, :js_tests]
