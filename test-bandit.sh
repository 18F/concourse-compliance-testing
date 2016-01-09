#!/bin/bash
pip install bandit
bandit code/ -r -f json -o bandit.json
