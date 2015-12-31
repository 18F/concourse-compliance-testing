#!/bin/bash
npm install -g eslint
npm install -g eslint-config-angular
npm install -g eslint-plugin-angular
npm install -g eslint-config-dustinspecker

eslint code/ -f json -o results/eslint.json
