#!/bin/bash

. .env

echo
echo "Integrating with Shorebird"
shorebird login
flutter build apk
shorebird init --display-name "${APP_DISPLAY_NAME}"
echo "Done"
