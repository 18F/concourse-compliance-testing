require 'minitest/autorun'
require_relative '../lib/zap_project'

describe ZAPProject do
  last_results_dir = "#{__dir__}/last_run"

  describe '.project_path' do
    it "should return the correct path for a project" do
      project = ZAPProject.new('fake-site-3', last_results_dir)
      assert_equal("#{__dir__}/last_run/fake-site-3.json", project.project_path)
    end
  end
end
