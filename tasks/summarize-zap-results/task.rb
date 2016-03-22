require_relative 'zap_result_scanner/lib/zap_result_comparator'

last_run_dir = "last-results/s3-bucket/results"
current_run_dir = "results"
output_dir = "zap-summary"

puts "Comparing last results to current results..."

ZAPResultComparator.write_summary(last_run_dir, current_run_dir, output_dir)

puts "Summary.json:"
puts `cat #{output_dir}/summary.json`
puts "Summary.txt:"
puts `cat #{output_dir}/summary.txt`
