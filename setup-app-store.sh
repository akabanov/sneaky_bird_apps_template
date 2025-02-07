#!/bin/bash

. .env

setup_app_store() {
  pushd 'ios' > /dev/null || return 1

  until bundle exec fastlane ios init_app; do
    echo "Retrying in 3 seconds "
    sleep 3
  done

  popd > /dev/null || return 1
}

setup_app_store
