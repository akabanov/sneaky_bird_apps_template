@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app_template/src/details.dart';
import 'package:flutter_app_template/src/home.dart';
import 'package:flutter_app_template/src/platform_screenshot_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'target_device.dart';

final metadataDirectory = Directory('metadata');

/// Converts raw screenshot into the final image
/// by adding texts, backgrounds, etc, to decorate the screenshot
typedef WidgetDecorator = Widget Function(Widget, Locale, TargetDevice);

/// Regular tests: `flutter test -x screenshots`
/// Screenshots generator: `flutter test --update-goldens --tags=screenshots`
///
/// These instructions are copied from
/// [Codemagic](https://docs.codemagic.io/knowledge-codemagic/flutter-screenshots-stores/).
void main() {
  testGoldens('Generate screenshots', (t) async {
    if (metadataDirectory.existsSync()) {
      metadataDirectory.deleteSync(recursive: true);
    }

    decorator(Widget w, Locale _, TargetDevice __) => w;

    await takeScreenshots(t, HomeScreen(), 'Home', decorator);
    await takeScreenshots(t, DetailsScreen(), 'Details', decorator);
  });
}

/// Creates a fake app around the widget to
/// supply target platform design, locale and mock providers.
Widget wrapInApp(Widget child, Locale locale, bool isAndroid, bool isFinal) {
  return ProviderScope(
    overrides: [
      platformScreenshotProvider.overrideWithValue(isAndroid),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: locale,
      theme: ThemeData(
        fontFamily: 'Roboto',
        platform: (isAndroid ? TargetPlatform.android : TargetPlatform.iOS),
      ),
      home: Column(
        children: [
          if (!isFinal) Container(color: Colors.black, height: 24),
          // fake, black and empty status bar, replace with whatever you like
          Expanded(child: child),
        ],
      ),
    ),
  );
}

int counter = 0;

/// Creates decorated widget screenshots for all supported locales and devices.
Future<void> takeScreenshots(WidgetTester t, Widget widget, String screenName,
    WidgetDecorator decorate) async {
  counter++;

  for (Locale locale in AppLocalizations.supportedLocales) {
    for (TargetDevice device in TargetDevice.values) {
      String decoratedName =
          '${device.isAndroid ? 'android' : 'ios'}/$locale/${counter.toString().padLeft(2, '0')}-$screenName-${device.name}';

      await takeScreenshot(t, widget, decoratedName, locale, device, false);
      var raw = loadAndDeleteImage(decoratedName);
      var decorated = decorate(raw, locale, device);
      await takeScreenshot(t, decorated, decoratedName, locale, device, true);
    }
  }
}

Future<void> takeScreenshot(WidgetTester t, Widget widget, String pagePath,
    Locale locale, TargetDevice device, bool isFinal) async {
  var inApp = wrapInApp(widget, locale, device.isAndroid, isFinal);

  await t.pumpWidgetBuilder(inApp);

  debugDisableShadows = false;

  await multiScreenGolden(
    t, '../../../metadata/$pagePath',
    // By default, the Golden Toolkit package uses pumpAndSettle(),
    // which can sometimes block the rendering if, for example,
    // there is an infinite animation.
    // Custom pump may help in such cases:
    // customPump: isFinal ? null : (tester) async =>
    //     await tester.pump(const Duration(milliseconds: 200)),
    devices: [
      Device(
        name: isFinal ? 'final' : rawScreenshotSuffix,
        size: device.logicalSize,
        textScale: 1,
        devicePixelRatio: device.density,
      )
    ],
  );

  debugDisableShadows = true;
}

var rawScreenshotSuffix = 'raw';

Image loadAndDeleteImage(String pageName) {
  final screenFile =
      File('${metadataDirectory.path}/$pageName.$rawScreenshotSuffix.png');
  final memoryImage = MemoryImage(screenFile.readAsBytesSync());
  screenFile.deleteSync();
  return Image(image: memoryImage);
}
