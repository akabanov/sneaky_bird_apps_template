#!/bin/bash

. .env

echo "Adding Codemagic application: https://codemagic.io/apps"
CODEMAGIC_RESPONSE=$(curl https://api.codemagic.io/apps \
  -H "Content-Type: application/json" \
  -H "x-auth-token: $(cat "$CM_API_TOKEN_PATH")" \
  -s -d '{
   "repositoryUrl": "'"${GIT_REPO_URL}"'",
   "sshKey": {
     "data": "'"$(base64 -w0 < "$CM_GITHUB_SSH_KEY_PATH")"'",
     "passphrase": "'"${CM_GITHUB_SSH_KEY_PASS}"'"
   }
  }')

CODEMAGIC_APP_ID=$(echo "${CODEMAGIC_RESPONSE}" | jq -r '._id')
echo "Codemagic application ID: ${CODEMAGIC_APP_ID}"
echo "CODEMAGIC_APP_ID=${CODEMAGIC_APP_ID}" >> .env

echo "Adding secrets"

add_codemagic_secret() {
  local name="$1"
  local value="$2"

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

# Code signing private key
appKeysDir="${HOME}/.secrets/dev/${APP_NAME_SLUG}"
appKeyFile="${appKeysDir}/certificate_private_key"
if [ ! -f "$appKeyFile" ]; then
  mkdir -p "$appKeysDir"
  ssh-keygen -t rsa -b 2048 -m PEM -f "$appKeyFile" -q -N ""
fi
add_codemagic_secret "CERTIFICATE_PRIVATE_KEY" "$(cat "$appKeyFile")"

add_codemagic_secret "APP_STORE_CONNECT_ISSUER_ID" "$APP_STORE_CONNECT_ISSUER_ID"
add_codemagic_secret "APP_STORE_CONNECT_KEY_IDENTIFIER" "$APP_STORE_CONNECT_KEY_IDENTIFIER"
add_codemagic_secret "APP_STORE_CONNECT_PRIVATE_KEY" "$(cat "$APP_STORE_CONNECT_PRIVATE_KEY_PATH")"

add_codemagic_secret "SENTRY_ACCESS_TOKEN" "$(cat "$CM_SENTRY_TOKEN_PATH")"

# seems to be only required to 'produce' new app at app store
#add_codemagic_secret "FASTLANE_PASSWORD" "$(cat "$ITUNES_PASSWORD_PATH")"

