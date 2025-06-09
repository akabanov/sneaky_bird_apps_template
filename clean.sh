#!/bin/bash

flutter clean
flutter pub get > /dev/null

pushd ios || exit
[ -f Podfile.lock ] && rm Podfile.lock
which pod >/dev/null 2>&1 && pod install > /dev/null
popd || exit

pushd macos || exit
[ -f Podfile.lock ] && rm Podfile.lock
which pod >/dev/null 2>&1 && pod install > /dev/null
popd || exit
