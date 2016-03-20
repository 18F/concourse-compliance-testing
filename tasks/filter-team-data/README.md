# Filter Team Data task

Concourse task to normalize/filter project data from [the 18F Team API](https://team-api.18f.gov/public/api/).

## Local usage

This assumes a [Concourse](http://concourse.ci/) target named `lite`. Do the following from the top level of this repository.

1. Run the [`fetch-project-data`](../fetch-project-data.yml) task.
1. Run

    ```bash
    mkdir -p out
    fly execute -t lite -c tasks/filter-team-data/task.yml -i scripts=. -i projects-json=tmp --output results=out
    ```

## Tests

```bash
ruby test/team_data_filterer.rb
```
