Concourse CI Compliance Testing
=========

[![Build Status](https://travis-ci.org/18F/concourse-compliance-testing.svg?branch=master)](https://travis-ci.org/18F/concourse-compliance-testing)
[![Code Climate](https://codeclimate.com/github/18F/concourse-compliance-testing/badges/gpa.svg)](https://codeclimate.com/github/18F/concourse-compliance-testing)

This is a location for scripts, tasks, and pipelines for the [Compliance Toolkit project](https://github.com/18f/compliance-toolkit/).

## Running

The Concourse.ci site provides solid information for [Getting Started](http://concourse.ci/getting-started.html) with Concourse. [The Fly CLI](http://concourse.ci/fly-cli.html) is your primary tool for working with the platform. Requires Concourse v0.74.0+.

### Locally

After getting a local instance of Concourse up and running in Vagrant (by following the [Getting Started Guide](http://concourse.ci/getting-started.html)) and installing the Fly CLI, you will be set up for testing Concourse.

Individual [tasks](http://concourse.ci/tasks.html) are run via the `fly execute` command, and are documented individually. You can find them under [`tasks/`].

This will use the current folder as the `scripts` input, and put the output designated by `results` to the folder of the same name.

Once your individual tasks are functional, you will need to string them together into [pipelines](http://concourse.ci/pipeline-mechanics.html).

Pipelines can not be executed directly. Instead, you must upload the pipeline to the Concourse server, enable it, and (optionally) kick it off.

Sensitive and/or configuration information should not be stored in the pipelines themselves. Instead, variables should be replaced by `{{parameter}}` in the pipeline and the values should be put into a `config/local.yml` file. The `config/local.example.yml` file in this repository can be used as a base. **This file should never be checked in to source control.**

Uploading a pipeline is done via the `fly set-pipeline` command, which is included in a comment in [each pipeline file](pipelines/). Running `fly unpause-pipeline -p <pipeline name>` will allow the pipeline to be run.

### ci.cloud.gov

Running pipelines on ci.cloud.gov is identical to running pipelines locally, with the exception that you will need to log in to ci.cloud.gov. Assuming you have permissions:

1. Run:

    ```bash
    cp config/prod.example.yml config/prod.yml
    ```

1. Modify `config/prod.yml`.
1. Run:

    ```bash
    fly -t cloud login —c https://ci.cloud.gov
    fly -t cloud sync
    ./pipelines/zap/build > tmp/zap-pipeline.yml
    fly set-pipeline -t cloud -n -c tmp/zap-pipeline.yml -p zap --load-vars-from config/prod.yml
    ```

## Feedback

Give us your feedback! We'd love to hear it. [Open an issue and tell us what you think.](https://github.com/18f/concourse-compliance-testing/issues/new)

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
