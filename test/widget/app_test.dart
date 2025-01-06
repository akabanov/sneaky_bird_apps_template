import 'package:flutter_app_template/src/app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Init screen messages', () {
    testWidgets('Initial screen message', (tester) async {
      await tester.pumpWidget(App());

      expect(find.text('Hello'), findsOne);
    });
  });
}
