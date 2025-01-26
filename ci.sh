#!/bin/bash

. .env

WORKFLOW_ID="$1"
if [ -z "$WORKFLOW_ID" ]; then
  echo "Workflow Id parameter is required:"
  yq '.workflows | keys[]' codemagic.yaml
  exit 1
fi

if [ "$WORKFLOW_ID" == "ios-lane" ]; then
  LANE_NAME="$2"
  if [ -z "$LANE_NAME" ]; then
    echo "Lane name is not defined"
    exit 1
  fi
else
  QUICK_BUILD="${2:-false}"
fi


buildIdJson=$(curl "https://api.codemagic.io/builds" \
  -H "Content-Type: application/json" \
  -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
  -s -d '{
   "appId": "'"$CODEMAGIC_APP_ID"'",
   "workflowId": "'"${WORKFLOW_ID}"'",
   "branch": "'"$(git rev-parse --abbrev-ref HEAD)"'",
   "environment": {
     "variables": {
       "QUICK_BUILD": "'"$QUICK_BUILD"'",
       "LANE_NAME": "'"$LANE_NAME"'"
     }
   }
  }'
)

buildUrl="https://codemagic.io/app/${CODEMAGIC_APP_ID}/build/$(echo "$buildIdJson" | jq -r '.buildId')"
echo "TestFlight Build URL: ${buildUrl}"
xdg-open "$buildUrl" > /dev/null
