# Run ZAP task

Concourse task to execute [OWASP ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project).

## Usage

This assumes a [Concourse](http://concourse.ci/) target named `lite`.

1. Run the [`filter-project-data`](../filter-project-data/) task.
1. Run the following from the top level of this repository:

    ```bash
    fly execute -t lite -c tasks/run-zap/task.yml -i filtered-project-data=out -i scripts=.
    ```

### Docker

This is experimental...just keeping notes here.

1. Create a test user.
1. Manually authorize site for test user.
1. Create a `.env` file that contains the test user credentials.

    ```
    USER=...
    PASS=...
    ```

1. Run

    ```bash
    docker build -t zap-auth . && docker run --env-file .env zap-auth
    ```
