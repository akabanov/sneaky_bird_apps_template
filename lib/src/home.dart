import 'package:flutter/material.dart';
import 'package:flutter_app_template/src/l10n.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
      Text(
        L10n.of(context).initialGreeting,
        style: Theme.of(context).textTheme.displayMedium,
      ),
      SizedBox(height: 24),
      ElevatedButton(
        child: Text('Test Sentry integration'),
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Emulating failure'),
          ));
          throw Exception('Throwing error to Sentry');
        },
      )
    ]);
  }
}
