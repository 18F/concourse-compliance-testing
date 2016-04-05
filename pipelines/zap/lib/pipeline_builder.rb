require_relative 'pipeline_data'

# Renders the ERB template with the provided list of projects.
class PipelineBuilder
  attr_reader :projects

  def initialize(projects)
    @projects = projects.sort_by { |project| project['name'] }
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
