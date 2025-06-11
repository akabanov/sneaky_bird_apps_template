#!/bin/bash

. .env.build

echo
echo "Integrating with Shorebird"
shorebird login
flutter build apk
shorebird init --display-name "${APP_LABEL_DASHBOARD}"
echo "Done"
