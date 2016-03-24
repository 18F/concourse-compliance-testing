require 'minitest/autorun'
require_relative '../lib/zap_result_set'

class TestZAPResultSet < MiniTest::Test
  describe ZAPResultSet do
    curr_results_dir = "#{__dir__}/current_run"

    describe '.project_results' do
      it "returns an array of ZAPResultSet::Results" do
        results = ZAPResultSet.project_results("fake-site-2", curr_results_dir)
        assert results.is_a?(Array)
        assert results.first.is_a?(ZAPResultSet::Result)
        assert_equal 1, results.size
      end

      it "returns an empty array for a missig file" do
        results = ZAPResultSet.project_results('fake-site-x', curr_results_dir)
        assert_equal [], results
      end

      it "should strip .js and .css urls out" do
        # fake-site-1 has 6 results, with one .js and one .css url
        results = ZAPResultSet.project_results("fake-site-1", curr_results_dir)
        assert_equal 4, results.size
      end
    end

    describe ".paren_status_count" do
      it "should return the correct counts for current/fake-site-1" do
        counts = ZAPResultSet.paren_status_count("fake-site-1", curr_results_dir)
        assert_equal "(2/0/1/1)", counts
      end

      it "should return the correct counts for current/fake-site-2" do
        counts = ZAPResultSet.paren_status_count("fake-site-2", curr_results_dir)
        assert_equal "(0/1/0/0)", counts
      end
    end

    describe ".count_risk_levels" do
      it "should return correct status counts" do
        results = ZAPResultSet.project_results("fake-site-1", curr_results_dir)
        counts = ZAPResultSet.count_risk_levels(results)
        assert_equal({ high: 2, medium: 0, low: 1, informational: 1 }, counts)
      end
    end
  end
end
