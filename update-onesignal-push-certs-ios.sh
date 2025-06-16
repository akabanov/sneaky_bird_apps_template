#!/bin/bash

# Creates APNs (Apple Push Notification service) certificate if needed and uploads it to OneSignal.
# The local copy can be found at: "$HOME/.secrets/app/${APP_NAME_SNAKE}/apns_${FLAVOR}.*".
# The existing certificate will be updated only if it's expiring in 30 days or the local copy is missing.

if [ -z "$1" ]; then
  echo "Usage: ./setup-onesignal-ios.sh [flavor]"
  exit 1
fi

flavoredEnv=".env.build.$1"
if [ ! -f "$flavoredEnv" ]; then
  echo "Flavor env file not found: '$flavoredEnv'"
  exit 1
fi

pushd ios > /dev/null || exit
export FLUTTER_FLAVOR=$1
fastlane ios update_onesignal
popd > /dev/null || exit
