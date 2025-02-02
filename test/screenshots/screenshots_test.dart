@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sneaky_bird_apps_template/src/details.dart';
import 'package:sneaky_bird_apps_template/src/home.dart';
import 'package:sneaky_bird_apps_template/src/platform_screenshot_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'target_store.dart';

final metadataDirectory = Directory('metadata');

/// Converts raw screenshot into the final image
/// by adding texts, backgrounds, etc, to decorate the screenshot
typedef WidgetDecorator = Widget Function(Widget, Locale, TargetDevice);

/// Exclude screenshots generation from regular tests:
/// - `flutter test -x screenshots`
/// Screenshots generator:
/// - `flutter test --update-goldens --tags=screenshots-android`
/// - `flutter test --update-goldens --tags=screenshots-ios`
///
/// Originally based on Codemagic
/// [article](https://docs.codemagic.io/knowledge-codemagic/flutter-screenshots-stores/).
void main() {
  testGoldens('Generate Android screenshots',
      (t) async => generateScreenshots(t, TargetStore.playStore),
      tags: ['screenshots-android']);

  testGoldens('Generate iOS screenshots',
      (t) async => generateScreenshots(t, TargetStore.appStore),
      tags: ['screenshots-ios']);
}

void generateScreenshots(t, TargetStore store) async {
  if (store.directory.existsSync()) {
    store.directory.deleteSync(recursive: true);
  }

  decorator(Widget w, Locale _, TargetDevice __) => w;

  // Google Play Console requires at least 2 screenshots per device class
  await takeScreenshots(t, store, HomeScreen(), 'home', true, decorator);
  await takeScreenshots(t, store, DetailsScreen(), 'details', true, decorator);
}

int counter = 0;

/// Creates decorated widget screenshots for all supported locales and devices.
Future<void> takeScreenshots(WidgetTester t, TargetStore store, Widget widget,
    String baseName, bool frameIt, WidgetDecorator decorate) async {
  counter++;
  String indexedBaseName = '${counter.toString().padLeft(2, '0')}-$baseName';

  // TBD: frameIt

  for (Locale locale in store.locales) {
    for (TargetDevice device in store.devices) {
      String basePath = store.getPath(device, locale, indexedBaseName);

      await takeScreenshot(t, widget, basePath, locale, device, false);
      var raw = loadAndDeleteImage(basePath);
      var decorated = decorate(raw, locale, device);
      await takeScreenshot(t, decorated, basePath, locale, device, true);
    }
  }
}

Future<void> takeScreenshot(WidgetTester t, Widget widget, String basePath,
    Locale locale, TargetDevice device, bool isFinal) async {
  var inApp = wrapInApp(widget, locale, device.isAndroid, isFinal);

  await t.pumpWidgetBuilder(inApp);

  debugDisableShadows = false;

  await multiScreenGolden(
    t, '../../../$basePath',
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

/// Creates a fake app around the widget to load fonts,
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

var rawScreenshotSuffix = 'raw';

Image loadAndDeleteImage(String basePath) {
  final screenFile = File('$basePath.$rawScreenshotSuffix.png');
  final memoryImage = MemoryImage(screenFile.readAsBytesSync());
  screenFile.deleteSync();
  return Image(image: memoryImage);
}
