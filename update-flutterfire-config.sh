#!/bin/bash

# BIG FAT WARNING:
# You need to re-run the update any time that you:
# - Start supporting a new platform in your Flutter app, or
# - Start using a new Firebase service or product in your Flutter app,
#   especially if you start using sign-in with Google,
#   Crashlytics, Performance Monitoring, or Realtime Database.
# Re-running the update ensures that your Flutter app's Firebase configuration is up-to-date,
# and (for Android) automatically adds any required Gradle plugins to your app.

. .env.build
. setup-common.sh

FIRST_ARG=$1

update_flutterfire_config() {
  if ! command -v xcode-select --print-path &> /dev/null; then
    echo "Xcode is not installed. Skipping flutterfire config update."
    exit 1
  fi

  # Make sure we're logged in if running locally
  if [ -z "$CI" ] && gcloud auth list 2>&1 | grep -q "No credentialed accounts."; then
    gcloud auth login
  fi

  rm -f firebase.json
  for_each_flavor update_flutterfire_config_flavor
  
  if [[ "$FIRST_ARG" == "push" ]]; then
    git add -A .
    git commit -m "Generated: Flutterfire configuration update"
    git push
  fi
}

update_flutterfire_config_flavor() {
  jsonKeyTmpFile=tmp-firebase-key.json

  if [ -n "$CI" ]; then
    # Running on Codemagic
    jsonKeyVarName="FIREBASE_SERVICE_ACCOUNT_KEY_$1"
    jsonKeyContent="${!jsonKeyVarName}"

    if [ -z "$jsonKeyContent" ]; then
      echo "Firebase json key ($jsonKeyVarName) is missing"
      exit 1
    fi

    echo "$jsonKeyContent" > "$jsonKeyTmpFile"
    export GOOGLE_APPLICATION_CREDENTIALS="$jsonKeyTmpFile"
  fi

# gcloud services enable firebaseauth.googleapis.com
# gcloud services enable firebasehosting.googleapis.com
# firebase experiments:enable webframeworks
# ...

  # This order of platforms/ios-build-config parameters is important
  # to correctly populate all the elements of the `firebase.json` configuration file.

  for buildType in Debug Profile; do
    flutterfire config \
      --project="${APP_ID_SLUG}" \
      --out="lib/firebase_options_$1.dart" \
      --platforms=ios \
      --ios-bundle-id="${BUNDLE_ID}" \
      --ios-build-config="$buildType-$1" \
      --ios-out="ios/firebase/$1" \
      --yes
  done

  flutterfire config \
    --project="${APP_ID_SLUG}" \
    --out="lib/firebase_options_$1.dart" \
    --platforms=android,web,ios \
    --android-package-name="${ANDROID_PACKAGE_NAME}" \
    --android-out="android/app/src/$1/google-services.json" \
    --ios-bundle-id="${BUNDLE_ID}" \
    --ios-build-config="Release-$1" \
    --ios-out="ios/firebase/$1" \
    --yes

  unset GOOGLE_APPLICATION_CREDENTIALS
  rm -f "$jsonKeyTmpFile"
}

update_flutterfire_config
