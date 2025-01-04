#!/bin/bash

. .env

echo "Adding Codemagic application: https://codemagic.io/apps"
CODEMAGIC_RESPONSE=$(curl -H "Content-Type: application/json" \
     -H "x-auth-token: ${CM_API_TOKEN}" \
     -d '{
       "repositoryUrl": "'"${GIT_REPO_URL}"'",
       "sshKey": {
         "data": "'"${CM_GITHUB_SSH_KEY_BASE64}"'",
         "passphrase": "'"${CM_GITHUB_SSH_KEY_PASS}"'"
       }
     }' \
     -X POST https://api.codemagic.io/apps \
     2>>/dev/null)
CODEMAGIC_APP_ID=$(echo "${CODEMAGIC_RESPONSE}" | jq -r '._id')
echo "Codemagic application ID: ${CODEMAGIC_APP_ID}"
echo "CODEMAGIC_APP_ID=${CODEMAGIC_APP_ID}" >> .env

echo "Adding secrets"

add_codemagic_secret() {
  local name="$1"
  local value="$2"

  echo "$name"
  curl -H "Content-type: application/json" \
    -H "x-auth-token: $CM_API_TOKEN" \
    -d '{
     "key": "'"${name}"'",
     "value": "'"${value//$'\n'/\\n}"'",
     "group": "secrets",
     "secure": true
    }' \
    -X POST "https://api.codemagic.io/apps/${CODEMAGIC_APP_ID}/variables" >> /dev/null
}

add_codemagic_secret "APP_STORE_CONNECT_ISSUER_ID" "$APP_STORE_CONNECT_ISSUER_ID"
add_codemagic_secret "APP_STORE_CONNECT_KEY_IDENTIFIER" "$APP_STORE_CONNECT_KEY_IDENTIFIER"
add_codemagic_secret "APP_STORE_CONNECT_PRIVATE_KEY" "$APP_STORE_CONNECT_PRIVATE_KEY"

appKeysDir="${HOME}/.secrets/dev/${APP_NAME_KEBAB}"
appKeyFile="${appKeysDir}/certificate_private_key"
if [ ! -f "$appKeyFile" ]; then
  mkdir -p "$appKeysDir"
  ssh-keygen -t rsa -b 2048 -m PEM -f "$appKeyFile" -q -N ""
fi
add_codemagic_secret "CERTIFICATE_PRIVATE_KEY" "$(cat "$appKeyFile")"
echo "Done"
