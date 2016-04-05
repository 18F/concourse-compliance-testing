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
    # zap-cli `quick-scan` and `alerts` return an error code if there are any warnings - ignore them so the script doesn't fail
    zap-cli -v quick-scan --scanners xss "$TARGET" || true
    zap-cli alerts -l Informational -f json > "tmp/${NAME}.${LINK_COUNTER}.json" || true
    #touch "tmp/${NAME}.${LINK_COUNTER}.json"
    zap-cli session new
    let LINK_COUNTER+=1
  done

  # only build results if we should have results
  if [ "$LINK_COUNT" -gt 0 ]
  then
    jq --slurp '[.[] | .[]]' tmp/"${NAME}".*.json > "results/${NAME}.json"
  fi

  let COUNTER+=1
done

zap-cli shutdown
