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

The ZAP pipeline is templatized, so it needs to be built before it can be uploaded. Make sure that you are checked out to the branch that you wish to deploy.

### Local

The following assumes a Concourse target named `lite`. Run the following from this directory:

#### Setup

1. Run:

    ```shell
    cp config/local.example.yml config/local.yml
    ```

1. Modify `config/local.yml`.

#### To deploy

1. Ensure branch is pushed to GitHub.
1. Point to branch in your `config/local.yml`.
1. Run:

    ```shell
    rake local deploy
    ```

### Production

#### One-time

1. Run:

    ```shell
    cp config/prod.example.yml config/prod.yml
    ```

1. Modify `config/prod.yml`.
1. Run:

    ```shell
    fly -t cloud login -c https://ci.cloud.gov
    fly -t cloud sync
    ```

#### To deploy

1. Ensure branch is pushed to GitHub.
1. Point to branch in your `config/prod.yml`.
    * Make sure to re-deploy to point to `master` afterwards if you've changed it.
1. Run:

    ```shell
    rake prod deploy
    ```
