#!/bin/bash

. .env

echo
read -n 1 -s -r -p "Create cicd-${APP_NAME_KEBAB} notification channel in Slack; press any key when ready..."

echo
echo "Adding Codemagic application: https://codemagic.io/apps"
CODEMAGIC_RESPONSE=$(curl -H "Content-Type: application/json" \
     -H "x-auth-token: ${CODEMAGIC_API_TOKEN}" \
     -d '{
       "repositoryUrl": "'"${GIT_REPO_URL}"'",
       "sshKey": {
         "data": "'"${GITHUB_SSH_KEY_BASE64}"'",
         "passphrase": "'"${GITHUB_SSH_KEY_PASS}"'"
       }
     }' \
     -X POST https://api.codemagic.io/apps \
     2>>/dev/null)
CODEMAGIC_APP_ID=$(echo "${CODEMAGIC_RESPONSE}" | jq -r '._id')
echo "CODEMAGIC_APP_ID=${CODEMAGIC_APP_ID}" >> .env

echo "Codemagic application ID: ${CODEMAGIC_APP_ID}"
echo "Done"

echo
echo "Adding credentials"
echo "TODO"
echo "Done"

read -r -p "Start internal test release build for iOS in Codemagic? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  curl -H "Content-Type: application/json" \
    -H "x-auth-token: ${CODEMAGIC_API_TOKEN}" \
    -d '{
     "appId": "'"$CODEMAGIC_APP_ID"'",
     "workflowId": "iOS-internal-test-release",
     "branch": "master"
    }' \
    -X POST https://api.codemagic.io/builds
fi
