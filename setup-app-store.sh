#!/bin/bash

. .env

echo
echo "Creating new bundle ID"
APPLE_RESPONSE=$(app-store-connect bundle-ids create --json \
  --platform IOS --name "$APP_NAME_DISPLAY" "$APP_BUNDLE_ID")

APPLE_BUNDLE_IDENTIFIER_ID=$(echo "$APPLE_RESPONSE" | jq -r '.id')
echo "APPLE_BUNDLE_IDENTIFIER_ID=${APPLE_BUNDLE_IDENTIFIER_ID}" >> .env

APPLE_APP_ID_PREFIX=$(echo "$APPLE_RESPONSE" | jq -r '.attributes.seedId')
echo "APPLE_APP_ID_PREFIX=${APPLE_APP_ID_PREFIX}" >> .env

read -r -p "Edit capabilities? (Y/n) " YN
if [[ ! "$YN" =~ ^[nN] ]]; then
  xdg-open "https://developer.apple.com/account/resources/identifiers/bundleId/edit/${APPLE_BUNDLE_ID_ID}"
fi

echo "Adding new App."
echo -n "${APP_TIMESTAMP}" | xclip -selection clipboard
echo "Use app SKU (already in clipboard): ${APP_TIMESTAMP}"

read -n 1 -s -r -p "Press any key to open App Store Connect..."
xdg-open 'https://appstoreconnect.apple.com/apps'

read -r -p "Enter Apple application ID" APPLE_APPLICATION_ID
echo "APPLE_APPLICATION_ID=${APPLE_APPLICATION_ID}" >> .env

echo "Done"
