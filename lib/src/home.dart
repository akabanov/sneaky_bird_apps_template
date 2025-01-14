import 'package:flutter/material.dart';
import 'package:sneaky_bird_apps_template/src/l10n.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(
          L10n.of(context).initialGreeting,
          style: Theme.of(context).textTheme.displayMedium,
        ),
        Gap(24),
        ElevatedButton(
          child: Text('Test Sentry integration'),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Emulating failure'),
            ));
            throw Exception('Throwing error to Sentry');
          },
        ),
        Gap(24),
        ElevatedButton(
          child: Text('Show details'),
          onPressed: () => context.go('/details'),
        ),
      ]),
    );
  }
}
