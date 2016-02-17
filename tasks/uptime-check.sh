#!/bin/bash

set -e
set -x

apt-get update
apt-get -y install curl jq

URLS=$(cat scripts/targets.json | jq -r '.targets | .[] | .url')

while read -r URL; do
  curl --fail -I $URL
done <<< "$URLS"

echo "TASK COMPLETE"
