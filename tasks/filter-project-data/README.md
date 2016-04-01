# Filter Project Data task

Concourse task to merge data for a particular project from [`targets.json`](../../config/targets.json) with the data from [the 18F Team API](https://team-api.18f.gov/public/api/).

## Configuring projects

Any keys in [`targets.json`](../../config/targets.json) will override the corresponding values in the input (`project-data/project.json`). For example, having the following in `project.json`:

```javascript
{
  "name": "someproject",
  "otherfield": "something"
  // ...
}
```

and the following in `targets.json`:

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

will result in an output of

```javascript
{
  "name": "someproject",
  "links": [
    "https://staging.someproject.com"
  ],
  "otherfield": "something"
  // ...
}
```

## Local usage

This assumes a [Concourse](http://concourse.ci/) target named `lite`. Run the following from the top level of this repository:

```bash
wget https://team-api.18f.gov/public/api/projects/<project>/ tmp/project.json
mkdir -p out
fly execute -t lite -c tasks/filter-project-data/task.yml -i scripts=. -i project-data=tmp --output filtered-project-data=out
```
