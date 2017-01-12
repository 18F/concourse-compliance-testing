require 'rake/testtask'
require 'tempfile'
require 'yaml'
require_relative 'lib/pipeline_builder'
require_relative 'lib/team_data_filterer'

def log(msg)
  puts "INFO: #{msg}"
end

def error_and_quit(msg)
  STDERR.puts "ERROR: #{msg}"
  exit 1
end

def branch
  result = ENV['SCRIPT_BRANCH'] || `git rev-parse --abbrev-ref HEAD`.strip
  if result == 'HEAD'
    error_and_quit("Must be checked out to a branch, or specify SCRIPT_BRANCH environment variable.")
  end
  result
end

def config_path
  File.expand_path("../config/#{@target}.yml", __FILE__)
end

def fly_data(target)
  data = YAML.load_file(File.expand_path(File.join('~', '.flyrc')))
  data['targets'][target]
end

def origin(target)
  fly_data(target)['api']
end

def concourse_team(target)
  fly_data(target)['team']
end

desc "Build the ZAP pipeline."
task :build do
  builder = PipelineBuilder.new(TeamDataFilterer.targets)
  @file = Tempfile.create(['zap-pipeline', '.yml'])
  @file.write(builder.build)
  log("Wrote pipeline to #{@file.path}.")
end

task :verify_target do
  @target = ENV['TARGET']
  unless @target
    task = Rake.application.top_level_tasks.last
    error_and_quit("No target set. Usage:\n\n  TARGET=<fly_target> rake #{task}\n\n")
  end

  @origin = origin(@target)
end

desc "Updates the pipeline."
task set: [:verify_target, :build] do
  sh 'fly', 'set-pipeline',
    '-t', @target,
    '--load-vars-from', config_path,
    '-c', @file.path,
    '-n',
    '-p', 'zap',
    '-v', "script-branch=#{branch}"
end

desc "Unpauses the pipeline."
task unpause: :verify_target do
  sh 'fly', 'unpause-pipeline',
    '-t', @target,
    '--pipeline', 'zap'
end

desc "Open the pipeline in a browser."
task open: :verify_target do
  team = concourse_team(@target)
  sh 'open', "#{@origin}/teams/#{team}/"
end

desc "Build and update the pipeline on the given target."
task deploy: [:set, :unpause, :open] do
  log("Pipeline updated and unpaused.")
end

desc "Initialize the projects. This is safe to run repeatedly."
task init_targets: :verify_target do
  require 'yaml'
  require_relative 'lib/target_initializer'

  config = YAML.load_file(config_path)
  targets = TeamDataFilterer.targets
  initializer = TargetInitializer.new(config, targets)
  initializer.run

  puts "All targets initialized."
end

# Ruby tests
Rake::TestTask.new do |t|
  t.test_files = FileList['**/test_*.rb'].exclude('vendor/**/*')
end

task default: :test
