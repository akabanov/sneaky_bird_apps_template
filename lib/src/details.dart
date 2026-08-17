import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'env.dart';

/// Fake details screen to check navigation.
class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Details',
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
