#!/bin/bash

. .env

existingBundle=$(app-store-connect bundle-ids list --private-key "$(cat "$APP_STORE_CONNECT_PRIVATE_KEY_PATH")" \
  --json --strict-match-identifier --bundle-id-identifier "$BUNDLE_ID")

if [[ $(echo "$existingBundle" | jq -r 'length') -eq '0' ]]; then
  echo "Creating new bundle ID"
  bundleDetails=$(app-store-connect bundle-ids create --private-key "$(cat "$APP_STORE_CONNECT_PRIVATE_KEY_PATH")" \
    --json --platform IOS --name "$APP_NAME_DISPLAY" "$BUNDLE_ID")
else
  echo "Bundle ${BUNDLE_ID} exists; saving details"
  bundleDetails=$(echo "$existingBundle" | jq -r '.[0]')
fi

APPLE_BUNDLE_IDENTIFIER_ID=$(echo "$bundleDetails" | jq -r '.id')
echo "APPLE_BUNDLE_IDENTIFIER_ID=${APPLE_BUNDLE_IDENTIFIER_ID}" >> .env

APPLE_APP_ID_PREFIX=$(echo "$bundleDetails" | jq -r '.attributes.seedId')
echo "APPLE_APP_ID_PREFIX=${APPLE_APP_ID_PREFIX}" >> .env

read -r -p "Edit bundle details? (Y/n) " YN
bundleDetailsUrl="https://developer.apple.com/account/resources/identifiers/bundleId/edit/${APPLE_BUNDLE_IDENTIFIER_ID}"
echo "Bundle details URL: ${bundleDetailsUrl}"
if [[ ! "$YN" =~ ^[nN] ]]; then
  xdg-open "$bundleDetailsUrl" >> /dev/null
fi

echo "Creating/updating app store application"
echo -n "${APP_TIMESTAMP}" | xclip -selection clipboard
echo "Use app SKU (already in clipboard): ${APP_TIMESTAMP}"

read -n 1 -s -r -p "Press any key to open App Store Connect... "
echo "App store apps URL: https://appstoreconnect.apple.com/apps"
xdg-open 'https://appstoreconnect.apple.com/apps' >> /dev/null

read -r -p "Enter Apple application ID: " APPLE_APPLICATION_ID
echo "APPLE_APPLICATION_ID=${APPLE_APPLICATION_ID}" >> .env
