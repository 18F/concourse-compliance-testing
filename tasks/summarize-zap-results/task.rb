require_relative 'lib/zap_result_set_comparator'

last_run_dir = "last-results/s3-bucket-results/results"
current_run_dir = "results"
output_dir = "zap-summary"

puts "Comparing last results to current results..."
ZAPResultSetComparator.write_summaries(last_run_dir, current_run_dir, output_dir)
puts "Done."

puts "Generated summary.json:"
puts `cat #{output_dir}/summary.json`
puts "Generated summary.txt:"
puts `cat #{output_dir}/summary.txt`
