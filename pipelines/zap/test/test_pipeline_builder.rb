require 'minitest/autorun'
require 'yaml'
require_relative '../lib/pipeline_builder'

describe PipelineBuilder do
  describe '#build' do
    def build_for(projects)
      builder = PipelineBuilder.new(projects)
      YAML.load(builder.build)
    end

    it "succeeds for an empty list of projects" do
      data = build_for([])
      data['jobs'].must_equal nil
    end

    it "adds an ondemand and a scheduled job for each project" do
      data = build_for([
        { 'name' => 'foo' },
        { 'name' => 'bar' }
      ])
      jobs = data['jobs'].map { |job| job['name'] }.sort
      jobs.must_equal %w(
        zap-ondemand-bar
        zap-ondemand-foo
        zap-scheduled-bar
        zap-scheduled-foo
      )
    end

    it "uses the specified Slack channel" do
      data = build_for([
        {
          'name' => 'foo',
          'slack_channel' => 'bar'
        }
      ])

      job = data['jobs'].first
      step = job['plan'].last
      step['on_success']['params']['channel'].must_equal '#bar'
    end

    it "uses the templatized Slack channel when none is specified" do
      builder = PipelineBuilder.new([
        { 'name' => 'foo' }
      ])
      yaml = builder.build
      # the Concourse template variable gets interpreted by YAML as a Hash, so check the unparsed version
      yaml.must_include 'channel: {{slack-channel}}'
    end
  end
end
