# Run ZAP task

Concourse task to execute [OWASP ZAP](https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project).

## Usage

This assumes a [Concourse](http://concourse.ci/) target named `lite`.

1. Run the [`filter-project-data`](../filter-project-data/) task.
1. Run the following from the top level of this repository:

    ```bash
    fly execute -t lite -c tasks/run-zap/task.yml -i filtered-project-data=out -i scripts=.
    ```
