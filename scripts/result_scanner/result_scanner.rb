#!/usr/bin/env ruby
require 'json'

module ResultScanner

  Result = Struct.new(:name, :confidence, :risk, :url, :param, :evidence, :alert)

  class << self

    # Call Me.
    def summarize_results(last_run_path, current_run_path, output_path)
      @final_json_out = {}
      @final_text_out = "Completed scan of #{json_files_from_dir(current_run_path).size} properties:"

      all_project_names(last_run_path, current_run_path).each do |proj|
        last_json = read_json(file_path_from_project_name(proj, json_files_from_dir(last_run_path)))
        current_json = read_json(file_path_from_project_name(proj, json_files_from_dir(current_run_path)))

        last_results = create_results(proj, last_json)
        current_results = create_results(proj, current_json)

        deltas = compute_risk_level_deltas(last_results, current_results)
        project_status = risk_level_delta_status_messages(deltas, last_json.empty?, current_json.empty?)

        @final_json_out.merge!({ proj => (count_risk_levels(current_results).merge(status: project_status)) })
        @final_text_out << "\n#{proj}: #{paren_status_count(current_results)} #{project_status}"
      end

      File.write("#{output_path}/summary.json", @final_json_out.to_json)
      File.write("#{output_path}/summary.txt", @final_text_out)
    end

    ############################################################################

    def json_files_from_dir(path)
      return Dir["#{path}/*.json"]
    end

    def write_file(file, contents)
      File.write('/path/to/file', 'Some glorious content')
    end

    def read_json(full_path)
      return full_path ? JSON.parse(File.read(full_path)) : {}
    end

    def project_name_from_file_path(file_path)
      return File.basename(file_path, ".json")
    end

    def file_path_from_project_name(project_name, file_paths)
      return file_paths.find{ |fp| fp.include?("/#{project_name}.json")}
    end

    def all_project_names(last_path, current_path)
      all_files = json_files_from_dir(last_path) + json_files_from_dir(current_path)
      all_names = all_files.map{ |f| project_name_from_file_path(f) }
      return all_names.uniq
    end

    # in:  "proj1", [{}, {}, ...]
    # out: [Result, ...]
    def create_results(project_name, json_results)
      return json_results.map do |jr|
        Result.new(project_name,
          jr['confidence'], jr['risk'], jr['url'], jr['param'], jr['evidence'],
          jr['alert']) unless is_js_or_css?(jr['url'])
      end.compact
    end

    # in:  [Result, Result, ...]
    # out: {:high => x, :medium => y, ...}
    def count_risk_levels(results)
      statuses = { high: 0, medium: 0, low: 0, informational: 0}
      results.each{ |r| statuses[r.risk.downcase.to_sym] += 1 }
      return statuses
    end

    # in:  [Result, ...], [Result, ...]
    # out: {increased_counts: {high: x, medium: y, ...}, decreased_counts: {...}}
    def compute_risk_level_deltas(old_results, new_results)
      deltas = {}
      deltas[:decreased_counts] = count_risk_levels(old_results - new_results)
      deltas[:increased_counts] = count_risk_levels(new_results - old_results)
      return deltas
    end

    # We are dropping all Results with `url` of .css or .js as a crude way
    #  of dealing with cache-busting urls.
    def is_js_or_css?(url)
      return url.match(/.js|.css/)
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

  end #/ class << self.

end #/ module
