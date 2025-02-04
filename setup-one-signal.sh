#!/bin/bash

. .env

while [ -z "$ONE_SIGNAL_ORG_ID" ]; do
  read -r -p "Enter OneSignal organisation ID: " ONE_SIGNAL_ORG_ID
done

appListJson=$(curl -s "https://api.onesignal.com/apps" \
  -H "Authorization: $(cat "$ONE_SIGNAL_API_KEY_PATH")" \
  -H 'accept: text/plain'
)

appJson=$(echo "$appListJson" | jq -r '.[] | select(.name == "'"${APP_LABEL_DASHBOARD}"'")')
if [ -z "$appJson" ]; then
  echo "Creating OneSignal app '${APP_LABEL_DASHBOARD}'"
  appJson=$(curl -s "https://api.onesignal.com/apps" \
    -H "Authorization: $(cat "$ONE_SIGNAL_API_KEY_PATH")" \
    -H 'Content-Type: application/json' \
    -H 'accept: text/plain' \
    -d '{
      "name": "'"$APP_LABEL_DASHBOARD"'",
      "organization_id": "'"$ONE_SIGNAL_ORG_ID"'"
    }'
  )
else
  echo "OneSignal app '${APP_LABEL_DASHBOARD}' already exists."
fi

ONE_SIGNAL_APP_ID=$(echo "$appJson" |  jq -r '.id')
echo "ONE_SIGNAL_APP_ID='${ONE_SIGNAL_APP_ID}'" >> .env
echo "OneSignal app ID: ${ONE_SIGNAL_APP_ID}"
