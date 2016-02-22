#!/bin/bash

set -e
set -x

npm install -g needle@^1.0.0
node ./scripts/tasks/uptime-check.js

echo "TASK COMPLETE"
