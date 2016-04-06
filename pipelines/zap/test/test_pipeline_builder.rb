require 'minitest/autorun'
require 'yaml'
require_relative '../lib/pipeline_builder'

describe PipelineBuilder do
  describe '#build' do
    it "succeeds for an empty list of projects" do
      builder = PipelineBuilder.new([])
      data = YAML.load(builder.build)
      data['jobs'].must_equal nil
    end

    it "adds an ondemand and a scheduled job for each project" do
      builder = PipelineBuilder.new([
        { 'name' => 'foo' },
        { 'name' => 'bar' }
      ])
      data = YAML.load(builder.build)
      jobs = data['jobs'].map { |job| job['name'] }.sort
      jobs.must_equal %w(
        zap-ondemand-bar
        zap-ondemand-foo
        zap-scheduled-bar
        zap-scheduled-foo
      )
    end
  end
end
