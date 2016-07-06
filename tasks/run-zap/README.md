# Run ZAP task

Concourse task to execute [OWASP ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project).

## Usage

This assumes a [Concourse](http://concourse.ci/) target named `lite`. Run the following from the top level of this repository, replacing `NAME` with the value from [`targets.json`](config/targets.json):

```bash
mkdir -p tmp/project-data
cat config/targets.json | jq '.[] | select(.name == "NAME")' > tmp/project-data/project.json
fly execute -t lite -c tasks/run-zap/task.yml -i project-data=tmp/project-data -i scripts=.
```
