import 'package:flutter/material.dart';
import 'package:flutter_skeleton_app/src/l10n.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        L10n.of(context).initialGreeting,
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}
