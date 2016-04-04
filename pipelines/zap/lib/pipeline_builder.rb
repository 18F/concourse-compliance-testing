require_relative 'pipeline_data'

class PipelineBuilder
  attr_accessor :projects

  def initialize(projects)
    self.projects = projects.sort_by { |project| project['name'] }
  end

  def build
    data = PipelineData.new(projects)
    template.result(data.internal_binding)
  end

  private

  # Returns an ERB instance.
  def template
    template_path = File.expand_path('../../pipeline.yml', __FILE__)
    contents = File.read(template_path)
    # support removal of trailing newlines
    ERB.new(contents, nil, '-')
  end
end
