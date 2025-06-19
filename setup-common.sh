#!/bin/bash

# quote-separated to survive the substitution
TEMPLATE_DOMAIN="example.""com"
TEMPLATE_DOMAIN_REVERSED="com.""example"
TEMPLATE_NAME_SNAKE="sneaky_bird_apps_""template"
TEMPLATE_NAME_CAMEL="sneakyBirdApps""Template"
TEMPLATE_APPLE_DEV_TEAM="QZUJZAGR""MU"

FLAVORS=("dev" "stg" "prod")

open_url() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    open "$1" > /dev/null &
  else
    xdg-open "$1" > /dev/null &
  fi
}

for_each_flavor() {
  local flavor_handler_name=$1
  for FLUTTER_FLAVOR in "${FLAVORS[@]}"; do
    local build_env_file_name=".env.build.$FLUTTER_FLAVOR"
    local runtime_env_file_name=".env.runtime.$FLUTTER_FLAVOR"
    # shellcheck disable=SC1090
    . "$build_env_file_name"
    $flavor_handler_name "$FLUTTER_FLAVOR" "$build_env_file_name" "$runtime_env_file_name"
  done
}

get_firebase_service_account_json_file() {
  echo "$HOME/.secrets/app/${APP_NAME_SNAKE}/firebase_$1_service_acc_key.json"
}

run_codemagic_build() {
  local workflowId="$1"
  local buildVariables="$2"

  . .env.build

  buildIdJson=$(curl "https://api.codemagic.io/builds" \
    -H "Content-Type: application/json" \
    -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
    -s -d '{
     "appId": "'"$CODEMAGIC_APP_ID"'",
     "workflowId": "'"${workflowId}"'",
     "branch": "'"$(git rev-parse --abbrev-ref HEAD)"'",
     "environment": {
       "variables": {'"$buildVariables"'}
     }
    }'
  )

  pauseSeconds=5
  buildUrl="https://codemagic.io/app/${CODEMAGIC_APP_ID}/build/$(echo "$buildIdJson" | jq -r '.buildId')"
  echo "Codemagic Build URL: ${buildUrl}"
  echo "Waiting ${pauseSeconds} seconds for build to start before opening the build page in browser..."

  sleep "$pauseSeconds"

  open_url "$buildUrl"
}
