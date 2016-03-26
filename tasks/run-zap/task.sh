#!/bin/bash

set -e
set -x

apt-get install jq
pip install --upgrade zapcli

NAME=$(jq -r .name < project-data/project.json)

zap-cli start --start-options '-config api.disablekey=true'

# TODO scan all links
TARGET=$(jq -r '.links | .[0] | .url' < project-data/project.json)

echo "Scanning $NAME: $TARGET"
# zap-cli returns an error code if there are any warnings - ignore them so the script doesn't fail
zap-cli -v quick-scan --spider --ajax-spider --scanners all "$TARGET" || true
zap-cli alerts -l Informational -f json > "results/${NAME}.json" || true

zap-cli shutdown
