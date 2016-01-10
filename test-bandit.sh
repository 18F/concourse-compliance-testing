#!/bin/bash
pip install bandit
bandit code/ -r -f json -o results/bandit.$(date -u +"%d%H%M").json
exit 0
