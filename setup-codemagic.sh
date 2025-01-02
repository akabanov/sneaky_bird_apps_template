#!/bin/bash

echo
read -n 1 -s -r -p "Create cicd-${APP_KEBAB} notification channel in Slack; press any key when ready..."

echo
echo "Adding Codemagic application: https://codemagic.io/apps"
CODEMAGIC_RESPONSE=$(curl -H "Content-Type: application/json" \
     -H "x-auth-token: ${CODEMAGIC_API_TOKEN}" \
     -d "{\"repositoryUrl\": \"${GIT_REPO_URL}\"}" \
     -X POST https://api.codemagic.io/apps \
     2>>/dev/null)
CODEMAGIC_APP_ID=$(echo "${CODEMAGIC_RESPONSE}" | jq -r '._id')
echo "Codemagic project ID: ${CODEMAGIC_APP_ID}"
echo "Done"

echo
echo "Adding credentials"
echo "TODO"
echo "Done"
