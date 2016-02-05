#!/bin/bash

zap-cli start --start-options '-config api.disablekey=true'
zap-cli open-url $LIVE_TARGET
zap-cli spider $LIVE_TARGET
zap-cli active-scan -s all -r $LIVE_TARGET
zap-cli alerts -l Informational -f json > results/zap.json
zap-cli shutdown

cp results/zap.json results.zap2.json

exit 0
