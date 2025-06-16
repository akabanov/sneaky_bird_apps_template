#!/bin/bash

# quote-separated to survive the substitution
TEMPLATE_DOMAIN="example.""com"
TEMPLATE_DOMAIN_REVERSED="com.""example"
TEMPLATE_NAME_SNAKE="sneaky_bird_apps_""template"
TEMPLATE_NAME_CAMEL="sneakyBirdApps""Template"
TEMPLATE_APPLE_DEV_TEAM="QZUJZAGR""MU"

FLAVORS=("dev" "stg" "prod")

for_each_flavor() {
  local flavor_handler_name=$1
  for FLUTTER_FLAVOR in "${FLAVORS[@]}"; do
    local build_env_file_name=".env.build.$FLUTTER_FLAVOR"
    local runtime_env_file_name=".env.runtime.$FLUTTER_FLAVOR"
    # shellcheck disable=SC1090
    . "$build_env_file_name"
    $flavor_handler_name "$FLUTTER_FLAVOR" "$build_env_file_name" "$runtime_env_file_name"
  done
}

gcloud_login() {
  echo "Choosing active google cloud account"
  GOOGLE_ACCOUNT=$(gcloud --quiet config get-value account 2>/dev/null)
  if [[ "$GOOGLE_ACCOUNT" == "(unset)" ]] || [[ -z "$GOOGLE_ACCOUNT" ]]; then
    echo "Not logged in. Starting authentication..."
    gcloud auth login
    GOOGLE_ACCOUNT=$(gcloud --quiet config get-value account 2>/dev/null)
  else
    echo "Currently logged in as: $GOOGLE_ACCOUNT"
    read -n 1 -r -p "Continue with this account? (Y/n) " YN && [[ "$YN" =~ ^[nN] ]] && gcloud auth login
    echo
  fi
}

update_flutterfire_config_flavor() {
# used in both setup.sh and update-flutterfire-config.sh.

# gcloud services enable firebaseauth.googleapis.com
# gcloud services enable firebasehosting.googleapis.com
# firebase experiments:enable webframeworks
# ...

#  flutterfire config \
#    --project="${APP_ID_SLUG}" \
#    --out="lib/firebase_options_$1.dart" \
#    --platforms=android,web,linux \
#    --android-package-name="${ANDROID_PACKAGE_NAME}" \
#    --android-out="android/app/src/$1/google-services.json" \
#    --yes

  for buildType in Debug Release; do
    flutterfire config \
      --project="${APP_ID_SLUG}" \
      --out="lib/firebase_options_$1.dart" \
      --platforms=ios \
      --ios-bundle-id="${BUNDLE_ID}" \
      --ios-build-config="$buildType-$1" \
      --ios-out="ios/$1" \
      --yes
  done
}

