#!/bin/bash

# Creates APNs (Apple Push Notification service) certificate if needed and uploads it to OneSignal

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
