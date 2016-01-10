#!/bin/bash
pip install bandit
bandit code/ -r -f json -o results/bandit.$(date -u +"%Y%m%dT%H%M%SZ").json
exit 0
