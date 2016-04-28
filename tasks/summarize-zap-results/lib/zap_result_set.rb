require 'json'
require_relative 'zap_project'

# Represents ZAP results for one project/run
class ZAPResultSet
  # Represents a single ZAP result
  Result = Struct.new(:name, :confidence, :risk, :url, :param, :alert)

  attr_reader :project

  def initialize(project_name, path)
    @project = ZAPProject.new(project_name, path)
  end

  def project_results
    json = strip_js_and_css(read_json)
    json_to_results(json)
  end

  def paren_status_count
    counts = count_risk_levels
    "(#{counts[:high]}/#{counts[:medium]}/#{counts[:low]}/#{counts[:informational]})"
  end

  def count_risk_levels
    self.class.count_risk_levels(project_results)
  end

  def missing?
    !project.source_exists?
  end

  def self.count_risk_levels(results)
    statuses = { high: 0, medium: 0, low: 0, informational: 0 }
    results.each { |result| statuses[result.risk.downcase.to_sym] += 1 }
    statuses
  end

  private

  # Previous or current result files could be missing. It's useful to think
  #  of a missing file producing an empty result, i.e. `[]` below.
  def read_json
    if project.source_exists?
      JSON.parse(File.read(project.project_path))
    else
      []
    end
  end

  # Transform json to ZAPResultSet::Results
  def json_to_results(json)
    json.map do |jr|
      uri = URI(jr['url'])
      # ignore the query string, since it may have some randomness
      uri.query = nil
      Result.new(project.name, jr['confidence'], jr['risk'], uri.to_s, jr['param'], jr['alert'])
    end
  end

  # We leave JS and CSS urls out of ZAP Results.
  def strip_js_and_css(json)
    json.reject { |record| record['url'].match(/.js|.css/) }
  end
end
