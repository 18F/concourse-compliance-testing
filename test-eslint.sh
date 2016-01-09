#!/bin/bash
npm install -g eslint
npm install -g eslint-config-angular
npm install -g eslint-plugin-angular
npm install -g eslint-config-dustinspecker
eslint . -f json -o results/eslint.json --ignore-path .gitignore
