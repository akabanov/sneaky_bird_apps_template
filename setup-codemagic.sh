#!/bin/bash

. .env

echo
read -n 1 -s -r -p "Create cicd-${APP_NAME_KEBAB} notification channel in Slack; press any key when ready..."
echo

echo
echo "Adding Codemagic application: https://codemagic.io/apps"
CODEMAGIC_RESPONSE=$(curl -H "Content-Type: application/json" \
     -H "x-auth-token: ${CM_API_TOKEN}" \
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
echo "Adding secrets"

add_codemagic_secret() {
  local name="$1"
  local value="$2"

  echo "$name"
  curl -H "Content-type: application/json" \
    -H "x-auth-token: $CM_API_TOKEN" \
    -d '{
     "key": "'"${name}"'",
     "value": "'"${value}"'",
     "group": "secrets",
     "secure": true
    }' \
    -X POST "https://api.codemagic.io/apps/${CODEMAGIC_APP_ID}/variables" >> /dev/null
}

add_codemagic_secret "APP_STORE_CONNECT_ISSUER_ID" "$APP_STORE_CONNECT_ISSUER_ID"
add_codemagic_secret "APP_STORE_CONNECT_KEY_IDENTIFIER" "$APP_STORE_CONNECT_KEY_IDENTIFIER"
add_codemagic_secret "APP_STORE_CONNECT_PRIVATE_KEY" "$APP_STORE_CONNECT_PRIVATE_KEY"

ssh-keygen -t rsa -b 2048 -m PEM -f temp_cert_key -q -N ""
# false-positive:
# shellcheck disable=SC2002
add_codemagic_secret "CERTIFICATE_PRIVATE_KEY" "$(cat temp_cert_key | base64 -w0)"
rm temp_cert_key

echo "Done"
