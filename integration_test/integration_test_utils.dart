import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

Future<void> takeScreenshot(WidgetTester tester,
    IntegrationTestWidgetsFlutterBinding binding, String baseName) async {
  if (!Platform.isAndroid) {
    await binding.takeScreenshot(baseName);
    return;
  }

  await binding.convertFlutterSurfaceToImage();
  await tester.pumpAndSettle();
  await binding.takeScreenshot('test-screenshot');
}
