#!/bin/bash

set -e
set -x

mkdir -p tmp

apt-get install jq
pip install --upgrade zapcli


NAME=$(jq -r .name < project-data/project.json)
LINK_COUNTER=0
LINK_COUNT=$(jq ".links | length" < project-data/project.json)
while [ "$LINK_COUNTER" -lt "$LINK_COUNT" ]; do
  TARGET=$(jq -r ".links | .[${LINK_COUNTER}] | .url" < project-data/project.json)

  echo "Scanning $NAME: $TARGET"
  zap-cli start --start-options '-config api.disablekey=true'
  # zap-cli `quick-scan` and `alerts` return an error code if there are any warnings - ignore them so the script doesn't fail
  zap-cli -v quick-scan --spider --ajax-spider --scanners all "$TARGET" || true
  zap-cli alerts -l Informational -f json > "tmp/${NAME}.${LINK_COUNTER}.json" || true
  zap-cli shutdown
  let LINK_COUNTER+=1
done

# only build results if we should have results
if [ "$LINK_COUNT" -gt 0 ]
then
  jq --slurp '[.[] | .[]]' tmp/"${NAME}".*.json > "results/${NAME}.json"
fi
