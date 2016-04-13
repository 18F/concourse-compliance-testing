# OWASP ZAP scanning pipeline

This pipeline scans the projects listed in [`targets.json`](../../config/targets.json) for vulnerabilities, using [OWASP ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project).

## Deployment

The ZAP pipeline is templatized, so it needs to be built before it can be uploaded. Make sure that you are checked out to the branch that you wish to deploy.

### Local

The following assumes a Concourse target named `lite`. Run the following from this directory:

1. Run:

    ```bash
    cp config/local.example.yml config/local.yml
    ```

1. Modify `config/local.yml`.
1. Run:

    ```bash
    rake local deploy
    ```

### Production

1. Run:

    ```bash
    cp config/prod.example.yml config/prod.yml
    ```

1. Modify `config/prod.yml`.
1. Run:

    ```bash
    fly -t cloud login -c https://ci-tooling.cloud.gov
    fly -t cloud sync
    cd pipelines/zap
    rake prod deploy
    ```
