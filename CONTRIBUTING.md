## Welcome!

We're so glad you're thinking about contributing to an 18F open source project! If you're unsure about anything, just ask -- or submit the issue or pull request anyway. The worst that can happen is you'll be politely asked to change something. We love all friendly contributions.

We want to ensure a welcoming environment for all of our projects. Our staff follow the [18F Code of Conduct](https://github.com/18F/code-of-conduct/blob/master/code-of-conduct.md) and all contributors should do the same.

We encourage you to read this project's CONTRIBUTING policy (you are here), its [LICENSE](LICENSE.md), and its [README](README.md).

If you have any questions or want to read more, check out the [18F Open Source Policy GitHub repository]( https://github.com/18f/open-source-policy), or just [shoot us an email](mailto:18f@gsa.gov).

## Public domain

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.

## Deployment

The Concourse.ci site provides solid information for [Getting Started](http://concourse.ci/getting-started.html) with Concourse. [The Fly CLI](http://concourse.ci/fly-cli.html) is your primary tool for working with the platform. Requires Concourse v0.74.0+.

It is recommended that you deploy [Compliance Viewer](https://github.com/18f/compliance-toolkit) first.

The ZAP pipeline is templatized, so it needs to be built before it can be uploaded. Make sure that you are checked out to the branch that you wish to deploy.

### Configuration

This one-time setup will need to be done once per environment you want to deploy to. The configuration file should be named to match your Concourse target name in `fly`.

1. Create a service key.

    ```sh
    cf create-service-key <s3_service_instance_name> pipeline-creds
    ```

1. Set up the configuration file.

    ```sh
    cp config/example.yml config/<fly_target>.yml
    ```

1. Fill in `<fly_target>.yml`.

### Fly

Run the following from this directory:

1. Ensure branch is pushed to GitHub.
1. Point to branch in your `config/<fly_target>.yml`.
1. Run:

    ```shell
    TARGET=<fly_target> rake deploy
    ```
