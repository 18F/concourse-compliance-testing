#!/bin/bash
pip install --upgrade git+https://github.com/Grunny/zap-cli.git

zap-cli quick-scan --spider -r -sc -o '-config api.disablekey=true' $LIVE_TARGET > results/zap.txt
exit 0
