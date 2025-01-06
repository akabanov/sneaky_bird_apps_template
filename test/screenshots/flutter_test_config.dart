import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

/// By default, flutter test only uses a single "test" font called Ahem.
/// This config loads any fonts included in the `pubspec.yaml`
/// as well as from packages the project depends on.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await loadAppFonts();
  return testMain();
}
