# Summarize ZAP Results Task

Concourse task to summarize differences between Last and Current ZAP result sets for a particular project. Differences are summarized and output as `summary.txt`.

## Use

In order to summarize results, this task needs `last-results`, `results`, and `project-data` as `input`. `run-zap` task results are stored in S3. `last-results` are generally downloaded before running ZAP and generating/uploading new `results`.

## Local usage

1. Get two sets of ZAP results either from local runs, or downloaded from the [Compliance Viewer](https://compliance-viewer.18f.gov/results).
1. Run the following from the top level of this repository:

    ```bash
    fly execute -t lite -c tasks/summarize-zap-results/task.yml -i results=<current-results-dir> -i last-results=<last-results-dir> -i scripts=. -i project-data=<project-data-dir>
    ```

## Running tests

```bash
ruby test/test_zap_project.rb && ruby test/test_zap_result_set.rb && ruby test/test_zap_result_set_comparator.rb
```
