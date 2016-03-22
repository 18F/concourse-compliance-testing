#!/usr/bin/env ruby
require_relative 'lib/zap_result_comparator'

# Scan ZAP Results and write `summary.json` and `summary.txt`
# Use: `ruby ./compare_zap_results <last_run_dir> <current_run_dir> <output_dir>
# ruby ./compare_zap_results.rb /Users/clintontroxel/dev/concourse-compliance-testing/scripts/zap_result_scanner/test/fixtures/last_run /Users/clintontroxel/dev/concourse-compliance-testing/scripts/zap_result_scanner/test/fixtures/current_run /Users/clintontroxel/dev/concourse-compliance-testing/scripts/zap_result_scanner

last_run_dir = ARGV[0]
current_run_dir = ARGV[1]
output_dir = ARGV[2]

ZAPResultComparator.write_summary(last_run_dir, current_run_dir, output_dir)
