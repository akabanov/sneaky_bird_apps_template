import 'package:flutter/material.dart';
import 'package:flutter_app_template/src/platform_screenshot_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Fake details screen to check navigation.
class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(context, ref) {
    return Scaffold(
      appBar: AppBar(
        leading: ScreenshotBackIconFactory.createBackIcon(ref),
      ),
      body: Center(
        child: Text(
          // This is to double check that the back button
          // is visible on the generated screenshots.
          'See the back button?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
