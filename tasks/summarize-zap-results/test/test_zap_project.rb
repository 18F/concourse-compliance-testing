require 'minitest/autorun'
require_relative '../lib/zap_project'

class TestZAPProject < MiniTest::Test
  describe ZAPProject do
    last_results_dir = "#{__dir__}/last_run"
    curr_results_dir = "#{__dir__}/current_run"

    describe '.count' do
      it "should count projects in a result directory" do
        assert_equal 2, ZAPProject.count(last_results_dir)
        assert_equal 2, ZAPProject.count(curr_results_dir)
      end
    end

    describe '.names' do
      it "should return an array of project names from a result directory" do
        last_projects = ZAPProject.names(last_results_dir)
        assert last_projects.is_a?(Array)
        assert last_projects.include?("fake-site-1")
        refute last_projects.include?("fake-site-2")
        assert last_projects.include?("fake-site-3")
      end
    end

    describe '.project_path' do
      it "should return the correct path for a project" do
        assert_equal(
          "#{__dir__}/last_run/fake-site-3.json",
          ZAPProject.project_path('fake-site-3', last_results_dir))
      end
    end

    describe '.missing_project_json?' do
      it "should return true if the project json file is missing" do
        refute ZAPProject.missing_project_json?("fake-site-3", last_results_dir)
        assert ZAPProject.missing_project_json?("fake-site-3", curr_results_dir)
      end
    end
  end
end
