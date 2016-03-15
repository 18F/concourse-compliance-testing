// usage:
//
//   # run fetch-project-data first
//   npm install
//   PROJECT_JSON=tmp/projects.json node tasks/uptime-check/task.js

'use strict';

const lib = require('./lib');

const json = lib.getProjectJson();
lib.checkProjects(json.results);
