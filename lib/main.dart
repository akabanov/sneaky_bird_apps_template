import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sneaky_bird_apps_template/src/app.dart';
import 'package:sneaky_bird_apps_template/src/env.dart';
import 'dart:io';

void main() async {
  tryInitOneSignal();
  runApp(App());
}

void tryInitOneSignal() {
  const appId = Env.oneSignalAppId;
  if (appId.isNotEmpty && (Platform.isIOS || Platform.isAndroid)) {
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
  }
}
