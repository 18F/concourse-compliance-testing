# roundabout way of passing template variables
# http://www.stuartellis.eu/articles/erb/#using-the-erb-library
class PipelineData
  attr_accessor :projects

  def initialize(projects)
    self.projects = projects
  end

  # needed for ERB
  def internal_binding
    binding
  end
end
