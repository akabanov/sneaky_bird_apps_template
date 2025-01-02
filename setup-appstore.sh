#!/bin/bash

. .env

echo

echo "Create a new App identifier for the application."
echo -n "${APP_BUNDLE_ID}" | xclip -selection clipboard
echo "Use app bundle ID (already in clipboard): ${APP_BUNDLE_ID}"

read -n 1 -s -r -p "Press any key to open Apple Dev Account..."
xdg-open 'https://developer.apple.com/account/resources/identifiers/list'

read -r -p "Enter App ID Prefix" APPLE_APP_ID_PREFIX
echo "APPLE_APP_ID_PREFIX=${APPLE_APP_ID_PREFIX}" >> .env

read -r -p "Enter identifier record ID" APPLE_IDENTIFIER_ID
echo "APPLE_IDENTIFIER_ID=${APPLE_IDENTIFIER_ID}" >> .env

echo "Add new App."
APP_SKU=$(date +%Y%d%m%H%M)
echo "APP_SKU=${APP_SKU}" >> .env
echo -n "${APP_SKU}" | xclip -selection clipboard
echo "Use app SKU (already in clipboard): ${APP_SKU}"

read -n 1 -s -r -p "Press any key to open App Store Connect..."
xdg-open 'https://appstoreconnect.apple.com/apps'

read -r -p "Enter application Apple ID" APPLE_APPLICATION_ID
echo "APPLE_APPLICATION_ID=${APPLE_APPLICATION_ID}" >> .env

echo "Done"
