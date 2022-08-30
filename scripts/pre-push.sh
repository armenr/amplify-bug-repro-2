#!/bin/bash
set -euo pipefail

echo "STEP ONE: [Pre-Push] script running!"

AWS_EXPORTS_JS="aws-exports.js"
AWS_EXPORTS_CJS="aws-exports.cjs"

echo "Checking if amplify config files exist"
if [[ -f amplify/.config/local-env-info.json ]] && [[ -f amplify/.config/project-config.json ]]; then
  echo "amplify config files do exist!"
  ROOT_PATH=$(jq <amplify/.config/local-env-info.json -r .projectPath)
  APP_REL_PATH=$(jq <amplify/.config/project-config.json -r .javascript.config.SourceDir)
  FULL_PATH=$ROOT_PATH/$APP_REL_PATH

  echo "checking if aws-exports.js exists"
  if [[ -f "${FULL_PATH}"/${AWS_EXPORTS_JS} ]]; then
    echo "aws-exports.js does exist"
    echo "Moving aws-exports.js to aws-exports.cjs to avoid nasty 'type: module' bug"
    mv "${FULL_PATH}"/${AWS_EXPORTS_JS} "${FULL_PATH}"/${AWS_EXPORTS_CJS} >/dev/null
  fi
fi
