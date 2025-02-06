#!/bin/bash

. .env

setup_app_store() {
  pushd 'ios' > /dev/null || return 1

  until bundle exec fastlane ios init_app; do
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
