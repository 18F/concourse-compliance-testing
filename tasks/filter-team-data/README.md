# Filter Team Data task

Concourse task to normalize/filter project data from [the 18F Team API](https://team-api.18f.gov/public/api/).

## Adding/configuring projects

The projects listed in the [`targets.json`](targets.json) file filter the data returned from the Team API. For example, having the following in `targets.json`:

```javascript
[
  {
    "name": "someproject"
  },
  // ...
]
```

will whitelist the project with the `name` of `someproject` from the Team API. `targets.json` also allows you to override attributes. For example:

```javascript
[
  {
    "name": "someproject",
    "links": [
      "https://staging.someproject.com"
    ]
  },
  // ...
]
```

will use the URL listed above, but all of the other attributes (`full_name`, etc.) will be inherited.

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
