require 'minitest/autorun'
require_relative '../lib/zap_result_set'

describe ZAPResultSet do
  curr_results_dir = "#{__dir__}/current_run"

  describe '.project_results' do
    it "returns an array of ZAPResultSet::Results" do
      result_set = ZAPResultSet.new('fake-site-2', curr_results_dir)
      assert result_set.project_results.is_a?(Array)
      assert result_set.project_results.first.is_a?(ZAPResultSet::Result)
      assert_equal 1, result_set.project_results.size
    end

    it "returns an empty array for a missig file" do
      result_set = ZAPResultSet.new('fake-site-x', curr_results_dir)
      assert_equal [], result_set.project_results
    end

    it "should strip .js and .css urls out" do
      # fake-site-1 has 6 results, with one .js and one .css url
      result_set = ZAPResultSet.new("fake-site-1", curr_results_dir)
      assert_equal 4, result_set.project_results.size
    end

    it "strips the query strings from the result URLs" do
      result_set = ZAPResultSet.new("fake-site-with-randomness", curr_results_dir)
      project_results = result_set.project_results
      assert_equal 1, project_results.size
      uri = URI(project_results.first['url'])
      assert_equal nil, uri.query
    end
  end

  describe ".paren_status_count" do
    it "should return the correct counts for current/fake-site-1" do
      result_set = ZAPResultSet.new('fake-site-1', curr_results_dir)
      assert_equal "(2/0/1/1)", result_set.paren_status_count
    end

    it "should return the correct counts for current/fake-site-2" do
      result_set = ZAPResultSet.new('fake-site-2', curr_results_dir)
      assert_equal "(0/1/0/0)", result_set.paren_status_count
    end
  end

  describe ".count_risk_levels" do
    it "should return correct status counts" do
      result_set = ZAPResultSet.new('fake-site-1', curr_results_dir)
      counts = result_set.count_risk_levels
      assert_equal({ high: 2, medium: 0, low: 1, informational: 1 }, counts)
    end
  end

  describe ".missing?" do
    it "should return true if the project file is missing" do
      refute ZAPResultSet.new('fake-site-1', curr_results_dir).missing?
      assert ZAPResultSet.new('fake-site-n', curr_results_dir).missing?
      refute ZAPResultSet.new('fake-site-0', curr_results_dir).missing?
    end
  end
end
