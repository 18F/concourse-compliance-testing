require 'minitest/autorun'
require_relative '../lib/zap_project'

class TestZAPProject < MiniTest::Test
  describe ZAPProject do
    last_results_dir = "#{__dir__}/last_run"
    curr_results_dir = "#{__dir__}/current_run"

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
