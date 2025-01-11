#!/bin/bash

. .env

setup_app_store() {
  pushd 'ios' > /dev/null || return 1

  bundle exec fastlane ios create
  bundle exec fastlane deliver init --skip_screenshots

  popd > /dev/null || return 1
}

setup_app_store
