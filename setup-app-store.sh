#!/bin/bash

. .env

setup_app_store() {
  pushd 'ios' > /dev/null || return 1

  until bundle exec fastlane ios create; do
    echo
    read -n 1 -r -p "App Store project creation has failed. Skip? (y/N) " YN
    echo
    if [[ "$YN" =~ ^[yY] ]]; then
      break
    fi
  done

  mv -f fastlane/Deliverfile fastlane/Deliverfile.stash
  until FASTLANE_PASSWORD=$(cat "$ITUNES_PASSWORD_PATH") bundle exec fastlane deliver init --skip_screenshots; do
    echo
    read -n 1 -r -p "Fastlane 'deliver init' has failed. Skip? (y/N) " YN
    echo
    if [[ "$YN" =~ ^[yY] ]]; then
      break
    fi
  done
  mv -f fastlane/Deliverfile.stash fastlane/Deliverfile

  until bundle exec fastlane ios deploy_meta; do
    echo
    read -n 1 -r -p "Uploading initial app metadata has failed. Skip? (y/N) " YN
    echo
    if [[ "$YN" =~ ^[yY] ]]; then
      break
    fi
  done

  popd > /dev/null || return 1
}

setup_app_store
