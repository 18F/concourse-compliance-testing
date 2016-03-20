#!/bin/bash

set -e
set -x

apt-get install jq
pip install --upgrade zapcli

COUNTER=0
COUNT=$(jq length < filtered-projects/projects.json)

zap-cli start --start-options '-config api.disablekey=true'

while [ "$COUNTER" -lt "$COUNT" ]; do
  NAME=$(jq -r ".[${COUNTER}] .name" < filtered-projects/projects.json)
  # TODO scan all links
  TARGET=$(jq -r ".[${COUNTER}] .links | .[0] | .url" < filtered-projects/projects.json)

  echo "Scanning $NAME: $TARGET"
  zap-cli -v quick-scan --spider --ajax-spider --scanners all "$TARGET"
  # `zap-cli alerts` returns an error code if there are any warnings - ignore them so the script doesn't fail
  zap-cli alerts -l Informational -f json > "results/${NAME}.json" || true
  zap-cli session new

  let COUNTER+=1
done

zap-cli shutdown
