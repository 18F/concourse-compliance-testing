#!/bin/bash

set -e
set -x

apt-get install jq
pip install --upgrade zapcli

COUNTER=0
COUNT=$(jq '.targets[] .url' < scripts/targets.json | wc -l)

zap-cli start --start-options '-config api.disablekey=true'

while [ "$COUNTER" -lt "$COUNT" ]; do
  NAME=$(jq ".targets[${COUNTER}] .name" -r < scripts/targets.json)
  TARGET=$(jq ".targets[${COUNTER}] .url" -r < scripts/targets.json)

  echo "Scanning $NAME: $TARGET"
  zap-cli -v quick-scan --spider --ajax-spider --scanners all "$TARGET"
  # `zap-cli alerts` returns an error code if there are any warnings - ignore them so the script doesn't fail
  zap-cli alerts -l Informational -f json > "results/${NAME}.json" || true
  zap-cli session new

  let COUNTER+=1
done

zap-cli shutdown
