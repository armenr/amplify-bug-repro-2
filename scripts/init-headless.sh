#!/bin/bash
set -e -o pipefail
IFS='|'
AWS_PROFILE_NAME=$1
AMPLIFY_APP_NAME=$2
AMPLIFY_BACKEND_NAME=$(git branch --show-current | tr "/" "-" | cut -c1-20)
AMPLIFY_HOOKS_DIR="amplify/hooks"

CLIENT_CONFIG="{\
\"SourceDir\":\"src\",\
\"DistributionDir\":\"dist\",\
\"BuildCommand\":\"pnpm run build\",\
\"StartCommand\":\"pnpm run serve\"\
}"

AWSCLOUDFORMATIONCONFIG="{\
\"configLevel\":\"project\",\
\"useProfile\":true,\
\"profileName\":\"${AWS_PROFILE_NAME}\"\
}"

AMPLIFY="{\
\"projectName\":\"${AMPLIFY_APP_NAME}\",\
\"defaultEditor\":\"code\",\
\"envName\":\"${AMPLIFY_BACKEND_NAME}\"\
}"

FRONTEND="{\
\"frontend\":\"javascript\",\
\"framework\":\"vue\",\
\"config\":$CLIENT_CONFIG\
}"

# !! AMPLIFY CLI BREAKS OTHERWISE!
PROVIDERS="'{\
\"awscloudformation\":$AWSCLOUDFORMATIONCONFIG\
}'"

cmd="amplify init project \
--amplify $AMPLIFY \
--frontend $FRONTEND \
--providers $PROVIDERS \
--yes"

echo "$cmd"
eval "$cmd"

if [[ -d ${AMPLIFY_HOOKS_DIR} ]]; then
  echo "Copying pull hooks!"
  cp scripts/*-pull.sh ${AMPLIFY_HOOKS_DIR}

  echo "Copying push hooks!"
  cp scripts/*-push.sh ${AMPLIFY_HOOKS_DIR}

  echo "Pushing/uploading hooks scripts to Amplify backend!"
  amplify push
fi

