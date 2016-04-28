require_relative 'zap_project'
require_relative 'zap_result_set'

# Compares two sets of ZAPResultSet::Results and writes summaries.
class ZAPResultSetComparator
  attr_reader :project_name, :curr_result_set, :last_result_set

  def initialize(project_name, last_run_dir, curr_run_dir)
    @project_name = project_name
    @curr_result_set = ZAPResultSet.new(project_name, curr_run_dir)
    @last_result_set = ZAPResultSet.new(project_name, last_run_dir)
  end

  def write_json_summary(output_dir)
    results = curr_result_set.count_risk_levels
    File.write("#{output_dir}/summary.json", results.to_json)
  end

  def write_slack_summary(output_dir)
    txt = "Completed scan of #{project_summary}"
    txt += "\n<https://compliance-viewer.18f.gov/results/#{project_name}/current|View results>"
    File.write("#{output_dir}/summary.txt", txt)
  end

  def no_change?
    project_statuses.empty? && !@curr_result_set.missing?
  end

  private

  def project_summary
    "#{project_name}: #{curr_result_set.paren_status_count} #{project_text}"
  end

  def project_text
    if last_result_set.missing?
      "NEW SITE"
    elsif curr_result_set.missing?
      "MISSING CURRENT DATA"
    elsif project_statuses.empty?
      "NO CHANGE"
    else
      "has " + project_statuses.join(', ')
    end
  end

  def project_statuses
    deltas = compute_risk_level_deltas
    dec = deltas[:decreased_counts]
    inc = deltas[:increased_counts]

    statuses = []
    [:high, :medium, :low, :informational].each do |level|
      statuses << "#{inc[level]} new #{level.upcase}" if inc[level] > 0
      statuses << "#{dec[level]} less #{level.upcase}" if dec[level] > 0
    end
    statuses
  end

  def compute_risk_level_deltas
    old_results = last_result_set.project_results
    new_results = curr_result_set.project_results

    fixes = old_results - new_results
    regressions = new_results - old_results

    {
      decreased_counts: ZAPResultSet.count_risk_levels(fixes),
      increased_counts: ZAPResultSet.count_risk_levels(regressions)
    }
  end
end
