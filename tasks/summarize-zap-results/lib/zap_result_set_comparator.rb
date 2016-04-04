require_relative 'zap_project'
require_relative 'zap_result_set'

# Compares two sets of ZAPResultSet::Results and writes summaries.
module ZAPResultSetComparator
  class << self
    def write_summaries(last_run_dir, curr_run_dir, output_dir)
      txt = summary_text(last_run_dir, curr_run_dir)
      File.write("#{output_dir}/summary.txt", txt)
    end

    private

    def summary_text(last_run_dir, curr_run_dir)
      summary = "Completed scan of #{ZAPProject.count(curr_run_dir)} properties:"
      all_projects(last_run_dir, curr_run_dir).each do |proj|
        status_count = ZAPResultSet.paren_status_count(proj, curr_run_dir)
        status_message = project_text(proj, last_run_dir, curr_run_dir)
        summary << "\n#{proj}: #{status_count} #{status_message}"
      end
      summary << "\n<https://compliance-viewer.18f.gov/results|View results>"
      summary
    end

    def project_text(proj, last_run_dir, curr_run_dir)
      statuses = project_statuses(proj, last_run_dir, curr_run_dir)
      if ZAPProject.missing_project_json?(proj, last_run_dir)
        "NEW SITE"
      elsif ZAPProject.missing_project_json?(proj, curr_run_dir)
        "MISSING CURRENT DATA"
      elsif statuses.empty?
        "NO CHANGE"
      else
        "has " + statuses.join(', ')
      end
    end

    def project_statuses(proj, last_run_dir, curr_run_dir)
      deltas = project_deltas(proj, last_run_dir, curr_run_dir)
      dec = deltas[:decreased_counts]
      inc = deltas[:increased_counts]

      statuses = []
      [:high, :medium, :low, :informational].each do |level|
        statuses << "#{inc[level]} new #{level.upcase}" if inc[level] > 0
        statuses << "#{dec[level]} less #{level.upcase}" if dec[level] > 0
      end
      statuses
    end

    def all_projects(last_run_dir, curr_run_dir)
      (ZAPProject.names(last_run_dir) + ZAPProject.names(curr_run_dir)).uniq
    end

    def project_deltas(proj, last_run_dir, curr_run_dir)
      compute_risk_level_deltas(
        ZAPResultSet.project_results(proj, last_run_dir),
        ZAPResultSet.project_results(proj, curr_run_dir)
      )
    end

    def compute_risk_level_deltas(old_results, new_results)
      {
        decreased_counts: ZAPResultSet.count_risk_levels(old_results - new_results),
        increased_counts: ZAPResultSet.count_risk_levels(new_results - old_results)
      }
    end
  end
end
