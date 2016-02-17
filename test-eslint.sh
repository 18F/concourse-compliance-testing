#!/bin/bash
npm install -g eslint eslint-config-angular eslint-plugin-angular eslint-config-dustinspecker
# in case the .gitignore doesn't exist
touch .gitignore
eslint . -f json -o results/eslint.json --ignore-path .gitignore
