require 'minitest/autorun'
require_relative '../lib/zap_result_set_comparator'

class TestZAPResultSetComparator < MiniTest::Test
  describe ZAPResultSetComparator do
    last_results_dir = "#{__dir__}/last_run"
    curr_results_dir = "#{__dir__}/current_run"

    describe '.write_summaries' do
      it "should write correct json to output dir" do
        Dir.mktmpdir do |output_dir|
          ZAPResultSetComparator.write_summaries(last_results_dir, curr_results_dir, output_dir)
          summary_json = JSON.parse(File.read("#{output_dir}/summary.json"))
          expected = {
            "fake-site-1" => { "high" => 2, "medium" => 0, "low" => 1, "informational" => 1, "status" => "has 2 new HIGH, 1 less MEDIUM, 1 less LOW, 1 new INFORMATIONAL, 1 less INFORMATIONAL" },
            "fake-site-3" => { "high" => 0, "medium" => 0, "low" => 0, "informational" => 0, "status" => "MISSING CURRENT DATA" },
            "fake-site-2" => { "high" => 0, "medium" => 1, "low" => 0, "informational" => 0, "status" => "NEW SITE" }
          }
          assert_equal expected, summary_json
        end
      end

      it "should write correct text file to output dir" do
        Dir.mktmpdir do |output_dir|
          ZAPResultSetComparator.write_summaries(last_results_dir, curr_results_dir, output_dir)
          summary_txt = File.read("#{output_dir}/summary.txt")
          expected = "Completed scan of 2 properties:\nfake-site-1: (2/0/1/1) has 2 new HIGH, 1 less MEDIUM, 1 less LOW, 1 new INFORMATIONAL, 1 less INFORMATIONAL\nfake-site-3: (0/0/0/0) MISSING CURRENT DATA\nfake-site-2: (0/1/0/0) NEW SITE\n<https://compliance-viewer.18f.gov/results|View results>"
          assert_equal expected, summary_txt
        end
      end
    end
  end
end
