#!/bin/bash

apt-get install jq
pip install tinys3

COUNTER=0
COUNT=$(cat scripts/targets.json | jq '.targets[] .url' | wc -l)


while [ $COUNTER -lt $COUNT ]; do
  NAME=$(cat scripts/targets.json | jq ".targets[${COUNTER}] .name" -r)
  TARGET=$(cat scripts/targets.json | jq ".targets[${COUNTER}] .url" -r)

  echo Scanning $NAME: $TARGET
  # Leaving ZAP up between runs allows alerts to accrue
  zap-cli start --start-options '-config api.disablekey=true'
  zap-cli open-url $TARGET
  zap-cli spider $TARGET
  zap-cli active-scan -s all -r $TARGET
  zap-cli alerts -l Informational -f json > results/${NAME}.json
  zap-cli shutdown

  let COUNTER+=1
done


echo Uploading files...
python scripts/s3upload.py

