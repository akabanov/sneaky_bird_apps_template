#!/bin/bash

# quote-separated to survive the initial setup substitution
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

# Google service acc secret file path convention
get_google_flavor_service_account_json_path() {
  local flavor="$1"
  local accountName="$2"
  echo "$HOME/.secrets/app/${APP_NAME_SNAKE}/google_service_account_${flavor}_${accountName}.json"
}

run_codemagic_build() {
  local workflowId="$1"
  local buildVariables="$2"

  . .env.build

  local cmApiToken
  cmApiToken=$(cat "$CM_API_TOKEN_PATH")
  buildIdJson=$(curl "https://api.codemagic.io/builds" \
    -H "Content-Type: application/json" \
    -H "x-auth-token: $cmApiToken" \
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
  buildId=$(echo "$buildIdJson" | jq -r '.buildId')
  buildPageUrl="https://codemagic.io/app/${CODEMAGIC_APP_ID}/build/${buildId}"
  echo "Codemagic Build URL: ${buildPageUrl}"
  echo "Waiting ${pauseSeconds} seconds for build to start before opening the build page in browser..."

  sleep "$pauseSeconds"
  open_url "$buildPageUrl"

  echo "Running the build"
  while true; do
    buildStatus=$(curl -s -H "Content-Type: application/json" \
      -H "x-auth-token: $cmApiToken" \
      "https://api.codemagic.io/builds/${buildId}" | jq -r '.build.status')

    case $buildStatus in
      "building"|"fetching"|"preparing"|"publishing"|"queued"|"testing")
        echo -n "."
        sleep "$pauseSeconds"
        ;;
      "finished")
        echo -e "\nBuild finished successfully"
        return 0
        ;;
      "failed"|"canceled"|"timeout"|"skipped"|"warning")
        echo -e "\nBuild failed with status: $buildStatus"
        return 1
        ;;
      *)
        echo -e "\nUnknown build status: $buildStatus"
        return 1
        ;;
    esac
  done
}
