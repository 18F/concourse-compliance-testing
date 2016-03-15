#!/bin/bash

set -e
set -x

cd scripts
npm install --production
node tasks/uptime-check/task.js

echo "TASK COMPLETE"
