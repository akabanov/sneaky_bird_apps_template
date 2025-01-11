#!/bin/bash

. .env

setup_app_store() {
  pushd 'ios' > /dev/null || return 1

  FASTLANE_PASSWORD=$(cat "$ITUNES_PASSWORD_PATH") bundle exec fastlane produce \
    -c "$APP_STORE_COMPANY_NAME" \
    -q "$APP_NAME_DISPLAY" \
    -a "$BUNDLE_ID" \
    -y "$APP_TIMESTAMP" \
    -m "$PRIMARY_APP_LANGUAGE"

  popd > /dev/null || return 1
}

setup_app_store
