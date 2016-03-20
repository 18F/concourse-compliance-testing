# Filter Team Data task

Concourse task to normalize/filter project data from [the 18F Team API](https://team-api.18f.gov/public/api/). The projects listed in the [targets](targets.json) file filter the data returned from the Team API, and override any attributes that are present.

## Local usage

This assumes a [Concourse](http://concourse.ci/) target named `lite`.

1. Run the [`fetch-project-data`](../fetch-project-data.yml) task.
1. Run the following from the top level of this repository:

    ```bash
    mkdir -p out
    fly execute -t lite -c tasks/filter-team-data/task.yml -i scripts=. -i projects-json=tmp --output filtered-projects=out
    ```

## Running tests

```bash
ruby test/team_data_filterer.rb
```
