#!/bin/bash
pip install bandit
bandit code/ -r -f json -o results/bandit.$(date -u +"%Y%m%d.%H%M%S").json
exit 0
