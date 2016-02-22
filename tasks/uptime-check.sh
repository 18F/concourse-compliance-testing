#!/bin/bash

set -e
set -x

npm install -g request@^2.69.0
node ./scripts/tasks/uptime-check.js

echo "TASK COMPLETE"
