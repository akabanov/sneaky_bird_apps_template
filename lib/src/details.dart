import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:sneaky_bird_apps_template/src/platform_screenshot_provider.dart';

import 'env.dart';

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
            Text('Sentry DSN:\n${Env.sentryDsn}', softWrap: true),
            Gap(24),
            Text('Sentry Dist:\n${Env.sentryDist}'),
            Gap(24),
            Text('OneSignal App Id:\n${Env.oneSignalAppId}'),
          ],
        ),
      ),
    );
  }
}
