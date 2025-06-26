import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sneaky_bird_apps_template/src/app.dart';
import 'package:sneaky_bird_apps_template/src/env.dart';
import 'dart:io';

void main() async {
  throw Exception("Can't run flavorless; use main_{flavor}.dart entry points");
}

Future<void> runMainApp(AsyncCallback appInit) async {
  await appInit();
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
