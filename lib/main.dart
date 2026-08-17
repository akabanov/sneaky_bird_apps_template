import 'dart:io';

import 'package:birdcorner_app_template/src/app.dart';
import 'package:birdcorner_app_template/src/env.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';

void main() async {
  throw Exception("Can't run flavorless; use main_{flavor}.dart entry points");
}

Future<void> runMainApp(FirebaseOptions firebaseOptions) async {
  await SentryFlutter.init(
    (options) {
      options.tracesSampleRate = 1.0;
      //options.profilesSampleRate = 1.0;
      options.debug = false;
    },
    appRunner: () async {
      Sentry.configureScope((scope) async {
        final sbPatch = await ShorebirdUpdater().readCurrentPatch();
        var tag = (sbPatch == null) ? 'release' : 'patch-${sbPatch.number}';
        return scope.setTag('shorebird', tag);
      });

      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(options: firebaseOptions);
      initOneSignal();
      return runApp(App());
    },
  );
}

void initOneSignal() {
  // OneSignal only supports mobile platforms
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    // OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
    OneSignal.initialize(Env.oneSignalAppId);
  }
}
