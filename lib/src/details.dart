import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sneaky_bird_apps_template/src/platform_screenshot_provider.dart';

/// Fake details screen to check navigation.
class DetailsScreen extends ConsumerWidget {
  const DetailsScreen({super.key});

  static const sentryDsn =
      String.fromEnvironment('SENTRY_DSN', defaultValue: 'missing');
  static const sentryDist =
      String.fromEnvironment('SENTRY_DIST', defaultValue: 'missing');

  @override
  Widget build(context, ref) {
    return Scaffold(
      appBar: AppBar(
        leading: ScreenshotBackIconFactory.createBackIcon(ref),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              // This is to double check that the back button
              // is visible on the generated screenshots.
              'See the back button?',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Gap(24),
            GestureDetector(
              child: Text(
                'Sentry DSN:\n$sentryDsn',
                softWrap: true,
              ),
              onTap: () {
                Clipboard.setData(const ClipboardData(text: sentryDsn));
              },
            ),
            Gap(24),
            Text('Sentry Dist: $sentryDist'),
          ],
        ),
      ),
    );
  }
}
