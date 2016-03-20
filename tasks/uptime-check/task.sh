#!/bin/bash

set -e
set -x

cd scripts/tasks/uptime-check
npm install --production
PROJECT_JSON=../../../filtered-projects/projects.json node task.js

echo "TASK COMPLETE"
