require 'minitest/autorun'
require_relative '../lib/zap_result_set_comparator'

class TestZAPResultSetComparator < MiniTest::Test
  describe ZAPResultSetComparator do
    last_results_dir = "#{__dir__}/last_run"
    curr_results_dir = "#{__dir__}/current_run"

    describe '.write_summary' do
      it "should write correct text file to output dir" do
        Dir.mktmpdir do |output_dir|
          comparator = ZAPResultSetComparator.new('fake-site-1', last_results_dir, curr_results_dir)
          comparator.write_summary(output_dir)
          summary_txt = File.read("#{output_dir}/summary.txt")
          expected = "Completed scan of fake-site-1: (2/0/1/1) has 2 new HIGH, 1 less MEDIUM, 1 less LOW, 1 new INFORMATIONAL, 1 less INFORMATIONAL\n<https://compliance-viewer.18f.gov/results/fake-site-1/current|View results>"
          assert_equal expected, summary_txt
        end
      end
    end

    it "should report NO CHANGE for two empty zap error sets" do
      Dir.mktmpdir do |output_dir|
        comparator = ZAPResultSetComparator.new('fake-site-0', last_results_dir, curr_results_dir)
        comparator.write_summary(output_dir)
        summary_txt = File.read("#{output_dir}/summary.txt")
        expected = "Completed scan of fake-site-0: (0/0/0/0) NO CHANGE\n<https://compliance-viewer.18f.gov/results/fake-site-0/current|View results>"
        assert_equal expected, summary_txt
      end
    end
  end
end
