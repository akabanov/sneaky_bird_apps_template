#!/bin/bash

. .env

workflow="$1"
if [ -z "$workflow" ]; then
  echo "Workflow Id parameter is required:"
  yq '.workflows | keys[]' codemagic.yaml
  echo '"ios-vanilla"'
  exit 1
fi

useShorebird="true"
if [ "$workflow" == "ios-vanilla" ]; then
  workflow="ios-beta"
  useShorebird="false"
elif [ "$workflow" == "ios-lane" ]; then
  laneName="$2"
  if [ -z "$laneName" ]; then
    echo "Lane name is not defined"
    exit 1
  fi
fi



buildIdJson=$(curl "https://api.codemagic.io/builds" \
  -H "Content-Type: application/json" \
  -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
  -s -d '{
   "appId": "'"$CODEMAGIC_APP_ID"'",
   "workflowId": "'"${workflow}"'",
   "branch": "'"$(git rev-parse --abbrev-ref HEAD)"'",
   "environment": {
     "variables": {
       "USE_SHOREBIRD": "'"$useShorebird"'",
       "LANE_NAME": "'"$laneName"'"
     }
   }
  }'
)

buildUrl="https://codemagic.io/app/${CODEMAGIC_APP_ID}/build/$(echo "$buildIdJson" | jq -r '.buildId')"
echo "TestFlight Build URL: ${buildUrl}"
xdg-open "$buildUrl" > /dev/null
