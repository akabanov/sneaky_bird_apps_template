import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sneaky_bird_apps_template/src/l10n.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
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
          Gap(24),
          ElevatedButton(
            child: Text('Enable notifications'),
            onPressed: () async {
              var state = ScaffoldMessenger.of(context);
              var permissionStatus = await Permission.notification.request();
              state.showSnackBar(SnackBar(
                content: Text('Permission status: ${permissionStatus.name}'),
              ));
            },
          )
        ]),
      ),
    );
  }
}
