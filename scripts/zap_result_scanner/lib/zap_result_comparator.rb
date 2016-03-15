require_relative 'zap_result'

module ZAPResultComparator
  class << self

    def write_summary(last_run_dir, curr_run_dir, output_dir)
      final_json_out = {}
      final_text_out = "Completed scan of #{ZAPResult.json_files_from_dir(curr_run_dir).size} properties:"

      ZAPResult.all_project_names(last_run_dir, curr_run_dir).each do |proj|
        last_results = ZAPResult.project_results(proj, last_run_dir)
        curr_results = ZAPResult.project_results(proj, curr_run_dir)
        curr_risk_levels = count_risk_levels(curr_results)

        project_deltas = compute_risk_level_deltas(last_results, curr_results)
        missing_last = ZAPResult.missing_project_json?(proj, last_run_dir)
        missing_curr = ZAPResult.missing_project_json?(proj, curr_run_dir)

        project_status = risk_level_delta_status_messages(project_deltas, missing_last, missing_curr)
        project_summary = curr_risk_levels.merge(status: project_status)

        final_json_out.merge!({ proj => project_summary })
        final_text_out << "\n#{proj}: #{paren_status_count(curr_results)} #{project_status}"
      end

      File.write("#{output_dir}/summary.json", final_json_out.to_json)
      File.write("#{output_dir}/summary.txt", final_text_out)
    end

    def count_risk_levels(results)
      statuses = { high: 0, medium: 0, low: 0, informational: 0}
      results.each{ |r| statuses[r.risk.downcase.to_sym] += 1 }
      return statuses
    end

    def compute_risk_level_deltas(old_results, new_results)
      return {
        decreased_counts: count_risk_levels(old_results - new_results),
        increased_counts: count_risk_levels(new_results - old_results)
      }
    end

    def risk_level_delta_status_messages(risk_level_deltas, missing_last, missing_current)
      return "NEW SITE" if missing_last
      return "MISSING CURRENT DATA" if missing_current

      dec = risk_level_deltas[:decreased_counts]
      inc = risk_level_deltas[:increased_counts]

      statuses = []
      [:high, :medium, :low, :informational].each do |level|
        statuses << "#{inc[level]} new #{level.upcase}" if inc[level] > 0
        statuses << "#{dec[level]} less #{level.upcase}" if dec[level] > 0
      end

      return "NO CHANGE" if statuses.empty?
      return "has " + statuses.join(', ')
    end

    def paren_status_count(results)
      counts = count_risk_levels(results)
      return "(#{counts[:high]}/#{counts[:medium]}/#{counts[:low]}/#{counts[:informational]})"
    end

  end
end
