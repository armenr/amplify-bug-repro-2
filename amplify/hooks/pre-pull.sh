#!/bin/bash
set -euo pipefail
# !!Note: SCRIPT RUNS IN REPO ROOT! All relative path references should be handled as such!

PRE_PULL_PACKAGE_JSON="package.json.amplify-pre-pull"

echo "STEP ONE: [Pre-PULL] script running!"
echo "    Stashing package.json"
cp package.json ${PRE_PULL_PACKAGE_JSON}

echo "    Removing type: module and writing modified package.json"
jq -c 'del(.type)' ${PRE_PULL_PACKAGE_JSON} > package.json
