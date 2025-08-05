#!/bin/bash

# Uploads FCM service account ('onesignal') credentials to OneSignal

. setup-common.sh

export FLUTTER_FLAVOR=$1
if [ -z "$FLUTTER_FLAVOR" ]; then
  echo "Usage: $0 {flavor}"
  exit 1
fi

flavoredEnv=".env.build.$FLUTTER_FLAVOR"
if [ ! -f "$flavoredEnv" ]; then
  echo "Flavor env file not found: '$flavoredEnv'"
  exit 1
fi

. .env.build
. $flavoredEnv
FCM_SERVICE_ACCOUNT_KEY_PATH=$(get_google_flavor_service_account_json_path "$FLUTTER_FLAVOR" "onesignal")
export FCM_SERVICE_ACCOUNT_KEY_PATH

pushd android > /dev/null || exit
fastlane android update_onesignal
popd > /dev/null || exit
