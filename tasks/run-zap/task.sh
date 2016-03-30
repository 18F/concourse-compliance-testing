#!/bin/bash

set -e
set -x

mkdir tmp

apt-get install jq
pip install --upgrade zapcli

COUNTER=0
COUNT=$(jq length < filtered-projects/projects.json)

zap-cli start --start-options '-config api.disablekey=true'

while [ "$COUNTER" -lt "$COUNT" ]; do
  NAME=$(jq -r ".[${COUNTER}] .name" < filtered-projects/projects.json)
  # TODO scan all links
  LINK_COUNTER=0
  LINK_COUNT=$(jq ".[${COUNTER}] .links | length" < filtered-projects/projects.json)
  while [ "$LINK_COUNTER" -lt "$LINK_COUNT" ]; do
    TARGET=$(jq -r ".[${COUNTER}] .links | .[${LINK_COUNTER}] | .url" < filtered-projects/projects.json)

    echo "Scanning $NAME: $TARGET"
    zap-cli -v quick-scan --spider --ajax-spider --scanners all "$TARGET"
    # `zap-cli alerts` returns an error code if there are any warnings - ignore them so the script doesn't fail
    zap-cli alerts -l Informational -f json > "tmp/${NAME}.${LINK_COUNTER}.json" || true
    zap-cli session new
    let LINK_COUNTER+=1
  done
  jq --slurp '[.[] | .[]]' tmp/${NAME}.*.json > results/${NAME}.json
  let COUNTER+=1
done

zap-cli shutdown
