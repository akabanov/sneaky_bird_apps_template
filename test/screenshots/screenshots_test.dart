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
final bool tabletPortrait = false;

final metadataDirectory = Directory('metadata');

/// Regular tests: `flutter test -x screenshots`
/// Screenshots generator: `flutter test --update-goldens --tags=screenshots`
///
/// These instructions are copied from
/// [Codemagic documentation pages](https://docs.codemagic.io/knowledge-codemagic/flutter-screenshots-stores/).
///
/// For each illustrated screenshot, here are the main steps to follow:
///
/// - First take a screenshot of the screen you want
/// - Load the generated image using [MemoryImage]
/// - Generate a new Flutter widget with all the needed decorations,
///   texts, backgrounds, etc, to decorate the screenshot
/// - Take a final screenshot of that widget
void main() {
  testGoldens('Generate screenshots', (t) async {
    if (metadataDirectory.existsSync()) {
      metadataDirectory.deleteSync(recursive: true);
    }

    await takeScreenshots(t, HomeScreen(), 'Home', (x) => x);
    await takeScreenshots(t, DetailsScreen(), 'Details', (x) => x);
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

  Size get sizeDp => tablet && tabletPortrait
      ? Size(height / density, width / density)
      : Size(width / density, height / density);

  /// Since the two iPads have exactly the same size,
  /// "iPad pro 6th gen" screenshot file names must contain a discriminator,
  /// other values are possible: https://docs.fastlane.tools/actions/deliver/
  String get baseName => name + (this == iPadPro6thGen ? '-ipadPro129' : '');

  bool get isAndroid => name.toLowerCase().contains('android');
}

/// returns the final screen to screenshot and here are its arguments:
///
/// The [child] argument is the screen you want to take a screenshot of.
///
/// The [locale] argument is the language you want to use for your screenshot.
///
/// The [isAndroid] argument is important here to get a rendering specific to each OS.
///
/// The [overrides] argument is useful to mock the logic of your app (database or webservices calls for example).
///
/// In that example, we use black for the status bar color,
/// which is a basic rectangle. Change it to whatever you want.
///
Widget wrapInApp(Widget child, Locale locale, bool isAndroid) {
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
          Container(color: Colors.black, height: 24),
          // fake, black and empty status bar, replace with whatever you like
          Expanded(child: child),
        ],
      ),
    ),
  );
}

int counter = 0;

/// The [widget] argument is the widget you want to screenshot.
///
/// The [pageName] argument is the name of the image file containing your screenshot.
/// Since you’ll take 2 screenshots per screen
/// (one for the screen itself, another one for the final illustration),
/// you’ll pass false for the isFinal argument here for the moment.
///
/// The [density] argument is the density of the device screen as specified above.
///
/// The [sizeDp] argument is the size of the device screen,
/// where its width and height have to be divided by the density.
/// For example, for the iPhone Xs Max, you’ll pass: `Size(1242 / 3, 2688 / 3)`.
///
/// The [customPump] argument of multiScreenGolden,
/// although not mandatory, can be useful in some cases.
/// By default, the Golden Toolkit package uses pumpAndSettle(),
/// which can sometimes block the rendering if, for example,
/// there is an infinite animation.
Future<void> takeScreenshots(WidgetTester t, Widget widget, String screenName,
    Widget Function(Widget w) decorate) async {
  counter++;

  for (Locale locale in AppLocalizations.supportedLocales) {
    for (TargetDevice device in TargetDevice.values) {
      String decoratedName =
          '${device.isAndroid ? 'android' : 'ios'}/$locale/${counter.toString().padLeft(2, '0')}-$screenName-${device.baseName}';

      var wrapped = wrapInApp(widget, locale, device.isAndroid);
      await takeScreenshot(t, wrapped, decoratedName, device, false);
      var rawScreenshotImage = loadScreenshotImage(decoratedName);
      var decorated = decorate(rawScreenshotImage);
      await takeScreenshot(t, decorated, decoratedName, device, true);
    }
  }
}

Future<void> takeScreenshot(WidgetTester t, Widget widget, String pagePath,
    TargetDevice device, bool isFinal) async {
  await t.pumpWidgetBuilder(widget);

  await multiScreenGolden(
    t, '../../../metadata/$pagePath',
    // use custom pump if rendering is blocked
    // (for example because of infinite animation).
    // customPump: isFinal
    //     ? null
    //     : (tester) async =>
    //         await tester.pump(const Duration(milliseconds: 200)),
    devices: [
      Device(
        name: isFinal ? 'final' : 'raw',
        size: device.sizeDp,
        textScale: 1,
        devicePixelRatio: device.density,
      )
    ],
  );
}

Image loadScreenshotImage(String pageName) {
  final screenFile = File('${metadataDirectory.path}/$pageName.raw.png');
  final memoryImage = MemoryImage(screenFile.readAsBytesSync());
  screenFile.deleteSync();
  return Image(image: memoryImage);
}
