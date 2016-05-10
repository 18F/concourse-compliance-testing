require 'minitest/autorun'
require_relative '../lib/zap_result_set_comparator'

describe ZAPResultSetComparator do
  last_results_dir = "#{__dir__}/last_run"
  curr_results_dir = "#{__dir__}/current_run"

  describe '.write_json_summary' do
    it "should write correct text file to output dir" do
      Dir.mktmpdir do |output_dir|
        comparator = ZAPResultSetComparator.new('fake-site-1', last_results_dir, curr_results_dir)
        comparator.write_json_summary(output_dir)
        data = JSON.load(File.new("#{output_dir}/summary.json"))
        expected = {
          'high' => 2,
          'medium' => 0,
          'low' => 1,
          'informational' => 1
        }
        assert_equal expected, data
      end
    end
  end

  describe '.write_slack_summary' do
    it "should write correct text file to output dir" do
      Dir.mktmpdir do |output_dir|
        comparator = ZAPResultSetComparator.new('fake-site-1', last_results_dir, curr_results_dir)
        comparator.write_slack_summary(output_dir)
        summary_txt = File.read("#{output_dir}/summary.txt")
        expected = "Completed scan of fake-site-1: (2/0/1/1) has 2 new HIGH, 1 less MEDIUM, 1 less LOW, 1 new INFORMATIONAL, 1 less INFORMATIONAL\n<https://compliance-viewer.18f.gov/results/fake-site-1/current|View results>"
        assert_equal expected, summary_txt
      end
    end
  end

  it "should report NO CHANGE for two empty zap error sets" do
    Dir.mktmpdir do |output_dir|
      comparator = ZAPResultSetComparator.new('fake-site-0', last_results_dir, curr_results_dir)
      comparator.write_slack_summary(output_dir)
      summary_txt = File.read("#{output_dir}/summary.txt")
      expected = "Completed scan of fake-site-0: (0/0/0/0) NO CHANGE\n<https://compliance-viewer.18f.gov/results/fake-site-0/current|View results>"
      assert_equal expected, summary_txt
    end
  end

  describe '.no_change?' do
    it "should return true if there is no change in status" do
      zr4 = ZAPResultSetComparator.new('fake-site-4', last_results_dir, curr_results_dir)
      zr0 = ZAPResultSetComparator.new('fake-site-0', last_results_dir, curr_results_dir)
      assert zr4.no_change?
      assert zr0.no_change?
    end

    it "should return false if there is a change in status" do
      zr1 = ZAPResultSetComparator.new('fake-site-1', last_results_dir, curr_results_dir)
      zr2 = ZAPResultSetComparator.new('fake-site-2', last_results_dir, curr_results_dir)
      zr3 = ZAPResultSetComparator.new('fake-site-3', last_results_dir, curr_results_dir)
      refute zr1.no_change?
      refute zr2.no_change?
      refute zr3.no_change?
    end

    it "returns true even if there is randomness in the results" do
      comparator = ZAPResultSetComparator.new('fake-site-with-randomness', last_results_dir, curr_results_dir)
      assert comparator.no_change?
    end
  end
end
