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
  gcloud_login
  for_each_flavor update_flutterfire_config_flavor
}

# testing on dev
. .env.build

. .env.build.dev
update_flutterfire_config_flavor dev

. .env.build.stg
update_flutterfire_config_flavor stg
