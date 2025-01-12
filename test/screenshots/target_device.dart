import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';

/// Use landscape if it makes sense for your app.
const bool landscapeOrientation = false;

/// https://www.ios-resolution.com/
enum TargetDevice {
  // Android Phone
  androidSmartphone(1107, 1968, 3),
  // Android Tablets
  sevenInchesAndroidTablet(1206, 2144, 2),
  tenInchesAndroidTablet(1449, 2576, 2),
  // iPhones
  iphone69(1320, 2868, 3),
  iphone67(1290, 2796, 3),
  iphone65(1284, 2778, 3), // has custom frame
  iphone63(1206, 2622, 3),
  iphone58(1170, 2532, 3), // has custom frame
  iphone55(1242, 2208, 3),
  iphone47(750, 1334, 2), // has custom frame
  iphone40(640, 1136, 2),
  iphone35(640, 960, 2),
  // iPads
  ipad130(2064, 2752, 2),
  ipad110(1668, 2388, 2), // has custom frame
  ipadPro129(2048, 2732, 2), // has custom frame
  ipad105(1668, 2224, 2),
  ipad97(1536, 2048, 2),
  ;

  static get shortList => const [
        androidSmartphone,
        sevenInchesAndroidTablet,
        tenInchesAndroidTablet,
        iphone69,
        iphone58,
        ipad130,
        ipad97,
      ];

  static get spareList => const [
        androidSmartphone,
        sevenInchesAndroidTablet,
        tenInchesAndroidTablet,
        iphone69,
        iphone58,
        iphone47,
        ipad130,
        ipadPro129,
        ipad97,
      ];

  static get framedAndMandatory => const [
        androidSmartphone,
        sevenInchesAndroidTablet,
        tenInchesAndroidTablet,
        iphone69,
        iphone65,
        iphone58,
        iphone47,
        ipad130,
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
