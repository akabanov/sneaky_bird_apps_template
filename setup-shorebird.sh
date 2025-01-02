#!/bin/bash

echo
echo "Integrating with Shorebird"
shorebird login
flutter build apk
shorebird init
echo "Done"
