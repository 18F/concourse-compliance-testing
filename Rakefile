require 'rake/testtask'

# Ruby tests
Rake::TestTask.new do |t|
  t.test_files = FileList['**/test_*.rb'].exclude('vendor/**/*')
end

desc "Run JavaScript tests"
task :js_tests do
  Dir.chdir('tasks/uptime-check') do
    sh 'mocha'
  end
end

task default: [:test, :js_tests]
