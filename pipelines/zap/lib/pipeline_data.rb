# roundabout way of passing template variables
# http://www.stuartellis.eu/articles/erb/#using-the-erb-library
class PipelineData
  attr_reader :projects

  def initialize(projects)
    @projects = projects
  end

  # needed for ERB
  def internal_binding
    binding
  end
end
