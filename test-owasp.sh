#!/bin/bash

apt-get install jq
pip install tinys3

COUNTER=0
COUNT=$(cat scripts/targets.json | jq '.targets[] .url' | wc -l)

zap-cli start --start-options '-config api.disablekey=true'

while [ $COUNTER -lt $COUNT ]; do
  NAME=$(cat scripts/targets.json | jq ".targets[${COUNTER}] .name" -r)
  TARGET=$(cat scripts/targets.json | jq ".targets[${COUNTER}] .url" -r)

  echo Scanning $NAME: $TARGET
  zap-cli open-url $TARGET
  zap-cli spider $TARGET
  zap-cli active-scan -s all -r $TARGET
  zap-cli alerts -l Informational -f json > results/${NAME}.json

  let COUNTER+=1
done

zap-cli shutdown

echo Uploading files...
python scripts/s3upload.py

