Concourse CI Compliance Testing
=========

[![Build Status](https://travis-ci.org/18F/concourse-compliance-testing.svg?branch=master)](https://travis-ci.org/18F/concourse-compliance-testing)
[![Code Climate](https://codeclimate.com/github/18F/concourse-compliance-testing/badges/gpa.svg)](https://codeclimate.com/github/18F/concourse-compliance-testing)

This is a location for scripts, tasks, and pipelines for the [Compliance Toolkit project](https://github.com/18f/compliance-toolkit/).

## Running

The Concourse.ci site provides solid information for [Getting Started](http://concourse.ci/getting-started.html) with Concourse. [The Fly CLI](http://concourse.ci/fly-cli.html) is your primary tool for working with the platform. Requires Concourse v0.74.0+.

### Locally

After getting a local instance of Concourse up and running in Vagrant (by following the [Getting Started Guide](http://concourse.ci/getting-started.html)) and installing the Fly CLI, you will be set up for testing Concourse.

Individual [tasks](http://concourse.ci/tasks.html) are run via the `fly execute` command, and are documented individually. You can find them under [`tasks/`](tasks/).

This will use the current folder as the `scripts` input, and put the output designated by `results` to the folder of the same name.

Once your individual tasks are functional, you will need to string them together into [pipelines](http://concourse.ci/pipeline-mechanics.html).

Pipelines can not be executed directly. Instead, you must upload the pipeline to the Concourse server, enable it, and (optionally) kick it off.

Sensitive and/or configuration information should not be stored in the pipelines themselves. Instead, variables should be replaced by `{{parameter}}` in the pipeline and the values should be put into a `config/local.yml` file. The `config/local.example.yml` file in this repository can be used as a base. **This file should never be checked in to source control.**

Uploading a pipeline is done via the `fly set-pipeline` command, which is included in a comment in [each pipeline file](pipelines/). Running `fly unpause-pipeline -p <pipeline name>` will allow the pipeline to be run.

### Production

See [the ZAP pipeline README](pipelines/zap/#production).

## Adding a Project

The [`config/targets.json`](config/targets.json) file acts as a whitelist against [the Team API list of projects](https://team-api.18f.gov/public/api/projects/). To get a new project added to the scans:

1. Ensure that your project appears in the [team-api](https://team-api.18f.gov/api/projects/). The directions for doing that are [here](https://github.com/18F/team-api.18f.gov#adding-project-data).
1. Submit a PR to this repo after [adding an entry in `config/targets.json`](https://github.com/18F/concourse-compliance-testing/edit/master/config/targets.json) like this:

    ```json
    {
      "name": "PROJECT NAME",
      "slack_channel": "CHANNEL FOR NOTIFICATIONS",
      "links": [
        {
          "url": "URL TO SCAN"
        }
      ]
    }
    ```

1. Ask someone in #compliance-toolkit to run

    ```bash
    rake prod init_targets
    ```

### Attributes

* `name` - This must match the `name` field from the team api, but should be all lowercase.
* `slack_channel` (optional) - This should be the channel where you'd like to get alerts for completed scans. If left out, the alerts will be sent to the default channel, currently `#ct-bot-attack`.
* `skip_team_api` (optional) - Set this to `true` if the project doesn't appear in the Team API.
* `links` - An array of links that should be scanned with ZAP. The results will be concatenated together. If left out, any `.gov` urls in your team api entry will be scanned.

For more information on the functionality available in `targets.json`, view the [filter-project-data README](https://github.com/18F/concourse-compliance-testing/blob/master/tasks/filter-project-data/README.md#configuring-projects).

### Deployment

After the PR is merged, someone with access to the Concourse server will need to redeploy the pipeline to start the scans. You can ask in #compliance-toolkit for assistance.

## Process Overview
### Inputs
The deployed pipeline depends on a few external systems to function. The [Team API](https://team-api.18f.gov/public/api/) is the source of information for all projects. A project should have a Team API entry, but it is not necessary to be scanned.

The running pipeline depends on [the pipeline repo](https://github.com/18F/concourse-compliance-testing) for [the tasks](https://github.com/18F/concourse-compliance-testing/tree/master/tasks) to be performed and [targets](https://github.com/18F/concourse-compliance-testing/blob/master/config/targets.json) to scan. By default, the pipeline pulls the `master` branch for these tasks, but it can be pointed at a different branch for testing.

### Outputs
Normal users of Compliance Toolkit do not need access to the Concourse CI. The pipeline publishes output in a few different modes.

Primarily, the pipeline publishes the ZAP scan results as a JSON file to S3. This is the information that is consumed by the user via Compliance Viewer.

The pipeline also published two types of Slack notifications. The first is a heartbeat notification; it is published to a central channel (currently #ct-bot-attack, but configurable in the pipeline) after every run to confirm that the run happened. This is for the Compliance Toolkit team to monitor that the process is functioning.

The second is for the project teams. It is published to the channel defined in `targets.json`, or the central channel (as the above notifications) if no channel is defined. It is only published if there is a change in the results. It also includes a link to the results in Compliance Viewer.

### Process
For each project, there are two jobs defined, a `scheduled` job, and an `on-demand` job. This is due to an oddity in the way Concourse jobs are triggered. If there is a time-based trigger defined, you can not run it at another time. The scheduled job runs every day at midnight. All the project scans are triggered simultaneously, but there are a limited number of workers available. The scans will be queued until a worker becomes available.

Each scan is a multi-step process:
1. Triggered at 12:00 AM.
1. Retrieves scripts to run from the GitHub repository.
1. Retrieves project information from the Team API and merges the `targets.json` information into it.
1. Retrieves the prior scan results from S3.
1. Performs some filtering/scrubbing of the prior scan results.
1. Run the ZAP scan via [zap-cli](https://github.com/Grunny/zap-cli). The ZAP scan has several sub steps of its own:
   1. Run the spider the current target.
   1. Run the AJAX spider for the current target.
   1. Scan the target.
   1. Output the detected alerts.
1. Repeat i-iv for every target defined for the project in targets.json.
1. Concatenate the results files into a single file.
1. Upload the results file to S3.
1. Summarize the results and the difference between the prior and current scan.
1. Post the two slack messages (heartbeat & notification, described above)
1. Upload the summary results to S3.

These steps are performed for each project in a parallelized fashion.

## Feedback
Give us your feedback! We'd love to hear it. [Open an issue and tell us what you think.](https://github.com/18f/concourse-compliance-testing/issues/new)

### Public domain

This project is in the worldwide [public domain](LICENSE.md). As stated in [CONTRIBUTING](CONTRIBUTING.md):

> This project is in the public domain within the United States, and copyright and related rights in the work worldwide are waived through the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).
>
> All contributions to this project will be released under the CC0 dedication. By submitting a pull request, you are agreeing to comply with this waiver of copyright interest.
