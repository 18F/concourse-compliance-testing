#!/bin/bash

zap-cli start --start-options '-config api.disablekey=true'
zap-cli open-url $LIVE_TARGET
zap-cli active-scan -s all -r $LIVE_TARGET
zap-cli alerts -l Low -f json > results/zap.json
zap-cli alerts -l Low -f html > results/zap.html
zap-cli shutdown

exit 0
