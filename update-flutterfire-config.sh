#!/bin/bash

# BIG FAT WARNING:
# You need to re-run the update any time that you:
# - Start supporting a new platform in your Flutter app, or
# - Start using a new Firebase service or product in your Flutter app,
#   especially if you start using sign-in with Google,
#   Crashlytics, Performance Monitoring, or Realtime Database.
# Re-running the update ensures that your Flutter app's Firebase configuration is up-to-date,
# and (for Android) automatically adds any required Gradle plugins to your app.

. setup-common.sh

update_flutterfire_config() {
  for_each_flavor update_flutterfire_config_flavor
}

update_flutterfire_config_flavor() {
  localKeyFile=$(get_firebase_service_account_json_file "$1")
  ciVarName="FIREBASE_SERVICE_ACCOUNT_KEY_$1"
  ciVarValue="${!ciVarName}"

  tmpKeyFile=tmp-firebase-key.json

  if [ -f "$localKeyFile" ]; then
    export GOOGLE_APPLICATION_CREDENTIALS="$localKeyFile"
  elif [ -n "$ciVarValue" ]; then
    export GOOGLE_APPLICATION_CREDENTIALS="$tmpKeyFile"
    echo "$ciVarValue" > "$GOOGLE_APPLICATION_CREDENTIALS"
  else
    echo "Firebase account key file not found neither in $localKeyFile file nor in $ciVarName variable"
    exit 1
  fi

# gcloud services enable firebaseauth.googleapis.com
# gcloud services enable firebasehosting.googleapis.com
# firebase experiments:enable webframeworks
# ...

  flutterfire config \
    --project="${APP_ID_SLUG}" \
    --out="lib/firebase_options_$1.dart" \
    --platforms=android,web,ios \
    --android-package-name="${ANDROID_PACKAGE_NAME}" \
    --android-out="android/app/src/$1/google-services.json" \
    --ios-bundle-id="${BUNDLE_ID}" \
    --ios-build-config="Profile-$1" \
    --ios-out="ios/firebase/$1" \
    --yes

  for buildType in Debug Release; do
    flutterfire config \
      --project="${APP_ID_SLUG}" \
      --out="lib/firebase_options_$1.dart" \
      --platforms=ios \
      --ios-bundle-id="${BUNDLE_ID}" \
      --ios-build-config="$buildType-$1" \
      --ios-out="ios/firebase/$1" \
      --yes
  done

  unset GOOGLE_APPLICATION_CREDENTIALS
  rm "$tmpKeyFile"
}

update_flutterfire_config
