require 'minitest/autorun'
require_relative '../lib/zap_result_comparator'

# For now, you should just be able to `ruby test_result_scanner.rb`

class TestZAPResultScanner < MiniTest::Test

  def setup
    @last_run_path = "#{__dir__}/fixtures/last_run"
    @curr_run_path = "#{__dir__}/fixtures/current_run"
    @last_json = ZAPResult.read_json("#{@last_run_path}/fake-site-1.json")
    @curr_json = ZAPResult.read_json("#{@curr_run_path}/fake-site-1.json")
    @last_results = ZAPResult.json_to_results("fake-site-1", @last_json)
    @curr_results = ZAPResult.json_to_results("fake-site-1", @curr_json)
    @deltas = ZAPResultComparator.compute_risk_level_deltas(@last_results, @curr_results)
  end

  def test_a_full_result_set
    Dir.mktmpdir do |dir|
      ZAPResultComparator.write_summary("#{__dir__}/fixtures/last_full_mp", "#{__dir__}/fixtures/current_full_mp", dir)
      summary_txt = File.read("#{dir}/summary.txt")
      summary_json = ZAPResult.read_json("#{dir}/summary.json")
      assert_match "micropurchase: (0/1/105/0) NO CHANGE", summary_txt
      assert_equal 105, summary_json["micropurchase"]["low"]
    end
  end

  def test_simple_integration
    Dir.mktmpdir do |dir|
      ZAPResultComparator.write_summary(@last_run_path, @curr_run_path, dir)
      summary_txt = File.read("#{dir}/summary.txt")
      summary_json = ZAPResult.read_json("#{dir}/summary.json")

      assert_match "Completed scan of 2 properties", summary_txt
      assert_match "fake-site-1: (2/0/1/1) has", summary_txt
      assert_match "fake-site-2: (0/1/0/0) NEW SITE", summary_txt
      assert_match "fake-site-3: (0/0/0/0) MISSING CURRENT DATA", summary_txt

      assert_equal 3, summary_json.keys.size
      assert summary_json.keys.include?("fake-site-1")
      site1_results = summary_json["fake-site-1"]
      assert site1_results.is_a?(Hash)
      assert_equal 2, site1_results["high"]
      assert_equal 0, site1_results["medium"]
      assert_match "has 2 new HIGH", site1_results["status"]
    end
  end

  def test_read_json_returns_json
    assert @last_json.is_a?(Array)
    assert @last_json.length > 0
  end

  def test_project_name_from_path
    assert_equal "project-1", ZAPResult.project_name_from_path("/A/long/path/to_a/file-named/project-1.json")
  end

  def test_project_path
    assert_equal "#{@curr_run_path}/fake-site-2.json", ZAPResult.project_path("fake-site-2", @curr_run_path)
    assert_equal "#{@curr_run_path}/fake-site-1.json", ZAPResult.project_path("fake-site-1", @curr_run_path)
  end

  def test_json_files_from_dir
    files = ZAPResult.json_files_from_dir("#{__dir__}/fixtures/current_run")
    assert_equal 2, files.size
    assert files.grep("fake-site-2.json")
  end

  def test_all_project_names
    all_names = ZAPResult.all_project_names(@last_run_path, @curr_run_path)
    assert_equal 3, all_names.size
    assert all_names.include?("fake-site-1")
    assert all_names.include?("fake-site-2")
    assert all_names.include?("fake-site-3")
  end

  def test_json_to_results
    assert_equal "fake-site-1", @last_results.first.name
    assert_equal "Medium", @last_results.first.confidence
    assert_equal "Medium", @last_results.first.risk
    assert_equal "https://micropurchase.18f.gov/sitemap.xml", @last_results.first.url
    assert_equal "", @last_results.first.param
    assert_equal "", @last_results.first.evidence
    assert_equal "X-Frame-Options Header Not Set", @last_results.first.alert
  end

  def test_missing_project_json
    assert ZAPResult.missing_project_json?('fake-site-3', @curr_run_path)
    refute ZAPResult.missing_project_json?('fake-site-1', @curr_run_path)
  end

  def test_count_statuses
    r1counts = ZAPResultComparator.count_risk_levels(@last_results)
    assert_equal 0, r1counts[:high]
    assert_equal 1, r1counts[:medium]
    assert_equal 2, r1counts[:low]
    assert_equal 1, r1counts[:informational]

    r2counts = ZAPResultComparator.count_risk_levels(@curr_results)
    assert_equal 2, r2counts[:high]
    assert_equal 0, r2counts[:medium]
    assert_equal 1, r2counts[:low]
    assert_equal 1, r2counts[:informational]
  end

  def test_risk_level_deltas
    assert_equal 2, @deltas[:increased_counts][:high]
    assert_equal 0, @deltas[:increased_counts][:medium]
    assert_equal 0, @deltas[:increased_counts][:low]
    assert_equal 1, @deltas[:increased_counts][:informational] # Notice increase+1

    assert_equal 0, @deltas[:decreased_counts][:high]
    assert_equal 1, @deltas[:decreased_counts][:medium]
    assert_equal 1, @deltas[:decreased_counts][:low]
    assert_equal 1, @deltas[:decreased_counts][:informational] # _and_ decrease+1
  end

  def test_risk_level_delta_status_messages
    status = ZAPResultComparator.risk_level_delta_status_messages(@deltas, false, false)
    assert_equal status, "has 2 new HIGH, 1 less MEDIUM, 1 less LOW, 1 new INFORMATIONAL, 1 less INFORMATIONAL"
  end

  def test_paren_status_count
    assert_equal "(2/0/1/1)", ZAPResultComparator.paren_status_count(@curr_results)
    assert_equal "(0/1/2/1)", ZAPResultComparator.paren_status_count(@last_results)
  end

  def test_no_change_status_message
    deltas = ZAPResultComparator.compute_risk_level_deltas([ZAPResult::Result.new], [ZAPResult::Result.new])
    message = ZAPResultComparator.risk_level_delta_status_messages(deltas, false, false)
    assert_match "NO CHANGE", message
  end

end
