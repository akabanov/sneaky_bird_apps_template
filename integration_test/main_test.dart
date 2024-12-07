import 'package:flutter/material.dart';
import 'package:flutter_skeleton_app/src/app.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding binding =
      IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App initialisation tests', () {
    testWidgets('Initial screen snapshot', (tester) async {
      runApp(App());

      await binding.convertFlutterSurfaceToImage();
      await tester.pumpAndSettle();
      await binding.takeScreenshot('initial-screen');
    });
  });
}
