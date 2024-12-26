import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

Future<void> main() async {
  await integrationDriver(
    onScreenshot: (String screenshotName, List<int> screenshotBytes,
        [Map<String, Object?>? args]) async {
      final Directory screenshotsDir = Directory('screenshots');
      if (!screenshotsDir.existsSync()) {
        screenshotsDir.createSync(recursive: true);
      }
      final File image = File('screenshots/$screenshotName.png');
      image.writeAsBytesSync(screenshotBytes);
      return true;
    },
  );
}
