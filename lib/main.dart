import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sneaky_bird_apps_template/src/app.dart';

void main() async {
  tryInitOneSignal();
  runApp(App());
}

void tryInitOneSignal() {
  var appId = String.fromEnvironment('ONESIGNAL_APP_ID');
  if (appId.isNotEmpty) {
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(appId);
  }
}
