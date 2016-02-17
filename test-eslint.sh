#!/bin/bash
npm install -g eslint eslint-config-angular eslint-plugin-angular eslint-config-dustinspecker
eslint . -f json -o results/eslint.json --ignore-path .gitignore
