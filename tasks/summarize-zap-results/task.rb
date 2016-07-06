require_relative 'lib/zap_result_set_comparator'
require_relative '../../lib/team_data_filterer'

last_run_dir = "last-results"
current_run_dir = "results"
output_dir = "zap-summary"

def project_name
  data = TeamDataFilterer.read_json('project-data/project.json')
  data['name']
end

puts "Comparing last results to current results..."
comparator = ZAPResultSetComparator.new(project_name, last_run_dir, current_run_dir)

comparator.write_json_summary(output_dir)

# If there is no change, do not write a summary. This prevents Slack from notifying.
# https://github.com/cloudfoundry-community/slack-notification-resource#parameters
if comparator.no_change?
  puts "No Change in ZAP results, omitting summary."
else
  comparator.write_slack_summary(output_dir)
  puts "Generated summary.txt:"
  puts `cat #{output_dir}/summary.txt`
end
puts "Done."
