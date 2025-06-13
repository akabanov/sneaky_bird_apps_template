import 'package:flutter/material.dart';
import 'package:sneaky_bird_apps_template/src/details.dart';
import 'package:sneaky_bird_apps_template/src/flavor_banner.dart';
import 'package:sneaky_bird_apps_template/src/home.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'l10n/app_localizations.dart';

class App extends StatelessWidget {
  App({super.key});

  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => HomeScreen(), routes: [
        GoRoute(path: 'details', builder: (_, __) => DetailsScreen())
      ])
    ],
  );

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        theme: ThemeData.light(useMaterial3: true),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
        routerConfig: router,
        builder: (context, child) {
          return FlavorBanner(
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}