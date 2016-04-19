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
ZAPResultSetComparator.write_summary(last_run_dir, current_run_dir, output_dir, project_name)
puts "Done."

puts "Generated summary.txt:"
puts `cat #{output_dir}/summary.txt`
