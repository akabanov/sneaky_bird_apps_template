#!/bin/bash

. .env

setup_app_store() {
  pushd 'ios' > /dev/null || return 1

  until bundle exec fastlane ios create; do
    echo "Retrying in 3 seconds "
    sleep 3
  done

  until FASTLANE_PASSWORD=$(cat "$ITUNES_PASSWORD_PATH") bundle exec fastlane produce enable_services --app_group --push-notification; do
    echo "Retrying in 3 seconds "
    sleep 3
  done

  until FASTLANE_PASSWORD=$(cat "$ITUNES_PASSWORD_PATH") bundle exec fastlane produce group -g "group.${BUNDLE_ID}.onesignal" -n "${APP_LABEL_DASHBOARDS} OneSignal"; do
    echo "Retrying in 3 seconds "
    sleep 3
  done

  until FASTLANE_PASSWORD=$(cat "$ITUNES_PASSWORD_PATH") bundle exec fastlane produce associate_group -a "$BUNDLE_ID" "group.${BUNDLE_ID}.onesignal"; do
    echo "Retrying in 3 seconds "
    sleep 3
  done

  mv -f fastlane/Deliverfile fastlane/Deliverfile.stash
  until FASTLANE_PASSWORD=$(cat "$ITUNES_PASSWORD_PATH") bundle exec fastlane deliver init --skip_screenshots; do
    echo "Retrying in 3 seconds "
    sleep 3
  done
  mv -f fastlane/Deliverfile.stash fastlane/Deliverfile

  until bundle exec fastlane ios deploy_meta; do
    echo "Retrying in 3 seconds "
    sleep 3
  done

  popd > /dev/null || return 1
}

setup_app_store
