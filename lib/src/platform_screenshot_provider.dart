import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/*
Use this factory in every Scaffold's AppBar which will appear on a screenshot:

extends ConsumerWidget {
...
Scaffold(
  appBar: AppBar(
    leading: ScreenshotBackIconFactory.createBackIcon(ref),
    ...
*/

/// This provider can be use anywhere in the app,
/// example is faking entered text in a [TextFormField].
final platformScreenshotProvider = Provider<bool?>((ref) => null);

/// Fake 'back' icon for screenshots where there's no Navigator
/// for the button to be shown automatically.
///
/// Usage:
///
/// ```dart
/// AppBar(leading: ScreenshotBackIconFactory.createBackIcon(ref), ...
/// ```
class ScreenshotBackIconFactory {
  static Widget? createBackIcon(WidgetRef ref) {
    var isAndroid = ref.read(platformScreenshotProvider);
    // in running app:
    if (isAndroid == null) {
      return null;
    }
    // in screenshot generator:
    return isAndroid
        ? Icon(Icons.arrow_back_sharp)
        : Icon(Icons.arrow_back_ios_sharp);
  }
}
