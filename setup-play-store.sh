#!/bin/bash

. .env

# Building app bundle for the initial upload to Play Console
flutter build appbundle
echo "Create an app in Google Play Console and upload the '.aab' bundle (Test and release > Internal testing)"
read -n 1 -s -r -p "Press any key when done..."
echo


