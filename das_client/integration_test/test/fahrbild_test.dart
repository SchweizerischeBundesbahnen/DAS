import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';

void main() {
  group('home screen test', () {
    testWidgets('load fahrbild company=1085, train=7839', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      await tester.pump(const Duration(seconds: 1));

      // Verify we have trainnumber with 9232.
      expect(find.text('7839'), findsOneWidget);

      // Verify we have company with 1088.
      expect(find.text('1085'), findsOneWidget);

      // check that the primary button is enabled
      var primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      // press load Fahrordnung button
      await tester.tap(primaryButton);

      // wait for fahrbild to load
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // check if station is present
      expect(find.text('SO_W'), findsOneWidget);
    });
  });
}
