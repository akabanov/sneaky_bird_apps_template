#!/bin/bash

. .env

echo "Adding Codemagic application: https://codemagic.io/apps"
CODEMAGIC_RESPONSE=$(curl https://api.codemagic.io/apps \
  -H "Content-Type: application/json" \
  -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
  -s -d '{
   "repositoryUrl": "'"${GIT_REPO_URL}"'",
   "sshKey": {
     "data": "'"$(base64 -w0 < "$CICD_GITHUB_SSH_KEY_PATH")"'",
     "passphrase": ""
   }
  }')

CODEMAGIC_APP_ID=$(echo "${CODEMAGIC_RESPONSE}" | jq -r '._id')
echo "Codemagic application ID: ${CODEMAGIC_APP_ID}"
echo "CODEMAGIC_APP_ID=${CODEMAGIC_APP_ID}" >> .env

echo "Adding secrets"

add_codemagic_secret() {
  local name="$1"
  local value="$2"

  if [ -z "$value" ]; then
    echo "Error: '$name' environment variable is not set."
    exit 1
  fi

  echo "$name"
  curl "https://api.codemagic.io/apps/${CODEMAGIC_APP_ID}/variables" \
    -H "Content-type: application/json" \
    -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
    -s -o /dev/null \
    -d '{
     "key": "'"${name}"'",
     "value": "'"${value//$'\n'/\\n}"'",
     "group": "secrets",
     "secure": true
    }'
}

# Developer ID
add_codemagic_secret "ITUNES_ID" "$ITUNES_ID"
add_codemagic_secret "APPLE_DEV_TEAM_ID" "$APPLE_DEV_TEAM_ID"
add_codemagic_secret "APP_STORE_CONNECT_TEAM_ID" "$APP_STORE_CONNECT_TEAM_ID"

# App store access
add_codemagic_secret "APP_STORE_CONNECT_ISSUER_ID" "$APP_STORE_CONNECT_ISSUER_ID"
add_codemagic_secret "APP_STORE_CONNECT_KEY_IDENTIFIER" "$APP_STORE_CONNECT_KEY_IDENTIFIER"
add_codemagic_secret "APP_STORE_CONNECT_PRIVATE_KEY" "$(cat "$APP_STORE_CONNECT_PRIVATE_KEY_PATH")"

# iOS signing certificates management
add_codemagic_secret "MATCH_GIT_URL" "$MATCH_GIT_URL"
add_codemagic_secret "MATCH_SSH_KEY" "$(cat "$CICD_GITHUB_SSH_KEY_PATH")"
add_codemagic_secret "MATCH_PASSWORD" "$(cat "$MATCH_PASSWORD_PATH")"

# Sentry access
add_codemagic_secret "SENTRY_AUTH_TOKEN" "$(cat "$SENTRY_CI_TOKEN_PATH")"

# Shorebird access
add_codemagic_secret "SHOREBIRD_TOKEN" "$(cat "$SHOREBIRD_TOKEN_PATH")"

# Contact details
add_codemagic_secret "DEV_FIRST_NAME" "$DEV_FIRST_NAME"
add_codemagic_secret "DEV_LAST_NAME" "$DEV_LAST_NAME"
add_codemagic_secret "DEV_PHONE" "$DEV_PHONE"
add_codemagic_secret "DEV_EMAIL" "$DEV_EMAIL"
add_codemagic_secret "DEV_WEBSITE" "$DEV_WEBSITE"
add_codemagic_secret "DEV_ADDRESS_LINE_1" "$DEV_ADDRESS_LINE_1"
add_codemagic_secret "DEV_ADDRESS_LINE_2" "$DEV_ADDRESS_LINE_2"
add_codemagic_secret "DEV_CITY" "$DEV_CITY"
add_codemagic_secret "DEV_STATE" "$DEV_STATE"
add_codemagic_secret "DEV_COUNTRY" "$DEV_COUNTRY"
add_codemagic_secret "DEV_ZIP" "$DEV_ZIP"
