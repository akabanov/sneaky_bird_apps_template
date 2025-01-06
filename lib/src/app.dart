import 'package:flutter/material.dart';
import 'package:flutter_app_template/src/details.dart';
import 'package:flutter_app_template/src/home.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      ),
    );
  }
}
