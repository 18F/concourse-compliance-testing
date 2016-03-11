Concourse CI Compliance Testing
=========

This is a location for scripts, tasks, and pipelines for the [Compliance Toolkit project](https://github.com/18f/compliance-toolkit/).

## Running

The Concourse.ci site provides solid information for [Getting Started](http://concourse.ci/getting-started.html) with Concourse. [The Fly CLI](http://concourse.ci/fly-cli.html) is your primary tool for working with the platform. Requires Concourse v0.74.0+.

### Locally

After getting a local instance of Concourse up and running in Vagrant (by following the [Getting Started Guide](http://concourse.ci/getting-started.html)) and installing the Fly CLI, you will be set up for testing Concourse.

Individual [tasks](http://concourse.ci/tasks.html) are run via the `fly execute` command, documented at the top of each `task.yml`. For example, you can run `zap-task` via the following:

```
fly execute --config tasks/zap-task.yml --input scripts=. --output results=results
```

This will use the current folder as the `scripts` input, and put the output designated by `results` to the folder of the same name.

Once your individual tasks are functional, you will need to string them together into [pipelines](http://concourse.ci/pipeline-mechanics.html).

Pipelines can not be executed directly. Instead, you must upload the pipeline to the Concourse server, enable it, and (optionally) kick it off.

Sensitive and/or configuration information should not be stored in the pipelines themselves. Instead, variables should be replaced by `{{parameter}}` in the pipeline and the values should be put into a `credentials.yml` file. The `credentials.example.yml` file in this repository can be used as a base. That example contains the fields required for the `zap-*` pipelines. **This file should never be checked in to source control.**

Uploading a pipeline is done via the `fly set-pipeline` command, which is included in a comment in [each pipeline file](pipelines/). Running `fly unpause-pipeline -p <pipeline name>` will allow the pipeline to be run.

### ci.cloud.gov

Running pipelines on ci.cloud.gov is identical to running pipelines locally, with the exception that you will need to log into ci.cloud.gov. Assuming you have permissions, you can log in with:

```bash
fly -t cloud login —c https://ci.cloud.gov
cp credentials.18F.example.yml credentials.18F.yml
# modify credentials.18F.yml
fly set-pipeline -t cloud -n -c pipelines/zap.yml -p zap --load-vars-from credentials.18F.yml
```

Note that you may need to re-download `fly` from [ci.cloud.gov](https://ci.cloud.gov) to ensure the versions match.

## Feedback

Give us your feedback! We'd love to hear it. [Open an issue and tell us what you think.](https://github.com/18f/concourse-compliance-testing/issues/new)

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
