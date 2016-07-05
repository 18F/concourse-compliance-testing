require 'rake/testtask'

# Ruby tests
Rake::TestTask.new do |t|
  t.test_files = FileList['**/test_*.rb'].exclude('vendor/**/*')
end

task default: :test
