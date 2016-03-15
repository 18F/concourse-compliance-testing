#!/bin/bash

set -e
set -x

cd scripts/tasks/uptime-check
npm install --production
node task.js

echo "TASK COMPLETE"
