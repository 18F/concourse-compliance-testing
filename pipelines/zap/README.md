# OWASP ZAP scanning pipeline

This pipeline scans the projects listed in [`targets.json`](../../config/targets.json) for vulnerabilities, using [OWASP ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project).

## Local usage

The ZAP pipeline is templatized, so it needs to be built before it can be uploaded to [Concourse](http://concourse.ci/).

The following assumes a Concourse target named `lite`. Run the following from the top level of this repository:

```bash
mkdir -p tmp
./pipelines/zap/build > tmp/zap-pipeline.yml
fly set-pipeline -t lite -n -c tmp/zap-pipeline.yml -p zap --load-vars-from config/local.yml -v script-branch=`git rev-parse --abbrev-ref HEAD`
```
