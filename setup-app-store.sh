#!/bin/bash

. .env

setup_app_store() {
  pushd 'ios' > /dev/null || return 1

  bundle exec fastlane ios create

  mv -f fastlane/Deliverfile fastlane/Deliverfile.stash
  FASTLANE_PASSWORD=$(cat "$ITUNES_PASSWORD_PATH") bundle exec fastlane deliver init --skip_screenshots
  mv -f fastlane/Deliverfile.stash fastlane/Deliverfile

  popd > /dev/null || return 1
}

setup_app_store
