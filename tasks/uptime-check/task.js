// usage:
//
//   # run fetch-project-data first, then run the following from this directory
//   npm install
//   PROJECT_JSON=../../tmp/projects.json node task.js

'use strict';

const lib = require('./lib');

const json = lib.getProjectJson();
lib.printLinkStatuses(json);
