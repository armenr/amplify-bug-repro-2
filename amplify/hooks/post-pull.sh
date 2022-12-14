#!/bin/bash
set -euo pipefail

echo "STEP TWO: [Post-Pull] script running!"

ROOT_PATH=$(jq <amplify/.config/local-env-info.json -r .projectPath)
APP_REL_PATH=$(jq <amplify/.config/project-config.json -r .javascript.config.SourceDir)
FULL_PATH=$ROOT_PATH/$APP_REL_PATH

AWS_EXPORTS_JS="aws-exports.js"
AWS_EXPORTS_TS="aws-exports.ts"
PRE_PULL_PACKAGE_JSON="package.json.amplify-pre-pull"
# AWS_EXPORTS_CJS="aws-exports.cjs"

if [[ -f amplify/.config/local-env-info.json ]] && [[ -f amplify/.config/project-config.json ]]; then

  if [[ -f "${FULL_PATH}"/${AWS_EXPORTS_JS} ]]; then
    echo "    Porting js exports to ts..."
    cp "${FULL_PATH}"/${AWS_EXPORTS_JS} "${FULL_PATH}"/${AWS_EXPORTS_TS} >/dev/null
    ed "${FULL_PATH}"/${AWS_EXPORTS_TS} <<<$'1d\nwq\n' >/dev/null
    ed "${FULL_PATH}"/${AWS_EXPORTS_TS} <<<$'1d\nwq\n' >/dev/null

    (
      echo "// !! WARNING: This file is autogenerated. DO NOT MAKE CHANGES BY HAND!" &&
        cat "${FULL_PATH}"/${AWS_EXPORTS_TS}
    ) >amplify/hooks/tmpfile.ts &&
      mv amplify/hooks/tmpfile.ts "${FULL_PATH}"/${AWS_EXPORTS_TS} >/dev/null
    #\ && rm -f "${FULL_PATH}"/${AWS_EXPORTS_JS}

    echo "    Linting & fixing ts exports file..."
    npm run lint:fix
  else
    echo "    ${FULL_PATH}/${AWS_EXPORTS_JS} does not exist."
    echo "    ...skipping!"
  fi
fi

if [[ -f ${PRE_PULL_PACKAGE_JSON} ]]; then
  echo "    Restoring package.json"
  mv ${PRE_PULL_PACKAGE_JSON} package.json
fi

# if [ -f "${FULL_PATH}"/${AWS_EXPORTS_CJS} ]; then
#   echo "    Found aws-exports CJS - removing..."
#   rm -f "${FULL_PATH}"/${AWS_EXPORTS_CJS}
# fi
