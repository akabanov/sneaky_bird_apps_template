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

/// If you want to display what your app looks like on a tablet,
/// prefer the portrait mode (if it still makes sense for your app, of course),
/// so your users can see more screens on the store without any swipe.
///
/// CHECK if it's suitable for iOS
final bool tabletLandscape = false;

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

/// Here are the size and densities that you can use for both
/// the Google Play Store and the App Store Connect:
enum TargetDevice {
  androidSmartphone('Android smartphone', 1107, 1968, 3, false),
  sevenInchesAndroidTablet('7 inches Android tablet', 1206, 2144, 2, true),
  tenInchesAndroidTablet('10 inches Android tablet', 1449, 2576, 2, true),
  iPadPro2ndGen('iPad pro 2nd gen', 2048, 2732, 2, true),
  iPadPro6thGen('iPad pro 6th gen', 2048, 2732, 2, true),
  iPhone8Plus('iPhone 8 Plus', 1242, 2208, 3, false),
  iPhoneXsMax('iPhone Xs Max', 1242, 2688, 3, false),
  ;

  final String label;
  final double width;
  final double height;
  final double density;
  final bool tablet;

  const TargetDevice(
      this.label, this.width, this.height, this.density, this.tablet);

  /// The [sizeDp] is the size of the device screen,
  /// where its width and height are divided by the density.
  /// For example, for the iPhone Xs Max, you’ll get: `Size(1242 / 3, 2688 / 3)`.
  Size get sizeDp => tablet && tabletLandscape
      ? Size(height / density, width / density)
      : Size(width / density, height / density);

  /// Since the two iPads have exactly the same size,
  /// "iPad pro 6th gen" screenshot file names must contain a discriminator,
  /// other values are possible: https://docs.fastlane.tools/actions/deliver/
  String get baseName => name + (this == iPadPro6thGen ? '-ipadPro129' : '');

  bool get isAndroid => name.toLowerCase().contains('android');
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
          '${device.isAndroid ? 'android' : 'ios'}/$locale/${counter.toString().padLeft(2, '0')}-$screenName-${device.baseName}';

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
        size: device.sizeDp,
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
