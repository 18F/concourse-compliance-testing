#!/bin/bash
pip install bandit
bandit code/ -r -f json -o results/bandit.json
exit 0
