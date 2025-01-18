import 'dart:io';

import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';

import 'ios_languages.dart';

/// Use landscape if it makes sense for your app.
const bool landscapeOrientation = false;

class TargetStore {
  static final playStore = TargetStore("android/fastlane/screenshots", [],
      TargetDevice.android, androidScreenshotFileName);

  static final appStore = TargetStore(
      "ios/fastlane/screenshots",
      getIosScreenshotLanguages(),
      // TargetDevice.ios,
      TargetDevice.iosShortList,
      // TargetDevice.iosMediumList,
      // TargetDevice.iosWithRealisticFrames,
      iosScreenshotFileName);

  final Directory directory;
  final List<Locale> locales;
  final List<TargetDevice> devices;
  final String Function(TargetDevice device, Locale locale, String baseName)
      fileName;

  TargetStore(String path, this.locales, this.devices, this.fileName)
      : directory = Directory(path);

  String getPath(TargetDevice device, Locale locale, String baseName) =>
      "${directory.path}/${fileName(device, locale, baseName)}";
}

String androidScreenshotFileName(
    TargetDevice device, Locale locale, String baseName) {
  throw UnimplementedError();
}

String iosScreenshotFileName(
    TargetDevice device, Locale locale, String baseName) {
  var countryCode = locale.countryCode;
  var code = (countryCode == null)
      ? locale.languageCode
      : '${locale.languageCode}-$countryCode';
  return '$code/$code-$baseName-${device.name}';
}

// https://www.ios-resolution.com/
// https://developer.apple.com/help/app-store-connect/reference/screenshot-specifications
// https://pub.dev/packages/device_frame
enum TargetDevice {
  // Android Phone
  androidSmartphone(1107, 1968, 3),
  // Android Tablets
  sevenInchesAndroidTablet(1206, 2144, 2),
  tenInchesAndroidTablet(1449, 2576, 2),
  // iPhones
  iphone69(1290, 2796, 3),
  iphone65(1284, 2778, 3), // has custom frame
  iphone63(1179, 2556, 3),
  iphone58(1170, 2532, 3), // has custom frame
  iphone55(1242, 2208, 3),
  iphone47(750, 1334, 2), // has custom frame
  iphone40(640, 1136, 2),
  iphone35(640, 960, 2),
  // iPads
  ipad130(2048, 2732, 2),
  ipad110(1668, 2388, 2), // has custom frame
  ipadPro129(2048, 2732, 2), // has custom frame
  ipad105(1668, 2224, 2),
  ipad97(1536, 2048, 2),
  ;

  static get android => TargetDevice.values.where((d) => d.isAndroid).toList();

  static get ios => TargetDevice.values.where((d) => !d.isAndroid).toList();

  static get iosShortList => const [
        iphone65,
        iphone47,
        ipadPro129,
        ipad110,
      ];

  static get iosMediumList => const [
        iphone69,
        iphone58,
        iphone47,
        ipad130,
        ipadPro129,
        ipad97,
      ];

  static get iosWithRealisticFrames => const [
        iphone65,
        iphone58,
        iphone47,
        ipad110,
        ipadPro129,
      ];

  const TargetDevice(this.width, this.height, this.density);

  final double width;
  final double height;
  final double density;

  bool get tablet => name.startsWith('ipad') || name.endsWith('Tablet');

  Size get logicalSize => landscapeOrientation
      ? Size(height / density, width / density)
      : Size(width / density, height / density);

  bool get isAndroid => name.toLowerCase().contains('android');

  DeviceInfo get frame {
    return switch (this) {
      iphone65 => Devices.ios.iPhone13ProMax, // or iPhone12ProMax
      iphone58 => Devices.ios.iPhone13, // or iPhone12
      iphone47 => Devices.ios.iPhoneSE,
      ipad110 => Devices.ios.iPadPro11Inches,
      ipadPro129 => Devices.ios.iPad12InchesGen2,
      _ => _genericFrame
    };
  }

  DeviceInfo get _genericFrame {
    var platform = isAndroid ? TargetPlatform.android : TargetPlatform.iOS;

    if (tablet) {
      return DeviceInfo.genericTablet(
          platform: platform,
          id: name,
          name: name,
          screenSize: Size(width, height),
          pixelRatio: density);
    } else {
      return DeviceInfo.genericPhone(
          platform: platform,
          id: name,
          name: name,
          screenSize: Size(width, height),
          pixelRatio: density);
    }
  }
}
