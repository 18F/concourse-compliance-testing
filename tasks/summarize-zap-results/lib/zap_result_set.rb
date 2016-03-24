require 'json'
require_relative 'zap_project'

# Represents ZAP results for one project/run
module ZAPResultSet
  # Represents a single ZAP result
  Result = Struct.new(:name, :confidence, :risk, :url, :param, :evidence, :alert)
  class << self
    def project_results(proj, results_dir)
      json = strip_js_and_css(read_json(proj, results_dir))
      json_to_results(proj, json)
    end

    def paren_status_count(proj, results_dir)
      results = project_results(proj, results_dir)
      counts = count_risk_levels(results)
      "(#{counts[:high]}/#{counts[:medium]}/#{counts[:low]}/#{counts[:informational]})"
    end

    def count_risk_levels(results)
      statuses = { high: 0, medium: 0, low: 0, informational: 0 }
      results.each { |result| statuses[result.risk.downcase.to_sym] += 1 }
      statuses
    end

    private

    # Previous or current result files could be missing. It's useful to think
    #  of a missing file producing an empty result, i.e. `[]` below.
    def read_json(proj, results_dir)
      path = ZAPProject.project_path(proj, results_dir)
      File.exist?(path) ? JSON.parse(File.read(path)) : []
    end

    # Transform json to ZAPResultSet::Results
    def json_to_results(project, json)
      json.map do |jr|
        Result.new(project, jr['confidence'], jr['risk'], jr['url'], jr['param'], jr['evidence'], jr['alert'])
      end.compact
    end

    # We leave JS and CSS urls out of ZAP Results.
    def strip_js_and_css(json)
      json.delete_if { |record| record['url'].match(/.js|.css/) }
    end
  end
end
