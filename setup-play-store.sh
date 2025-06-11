#!/bin/bash

. .env.build

# Building app bundle for the initial upload to Play Console
flutter build appbundle --flavor dev
echo "Create an app in Google Play Console and upload the '.aab' bundle (Test and release > Internal testing)"
read -n 1 -s -r -p "Press any key when done..."
echo


