import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';

void main() {
  group('home screen test', () {
    testWidgets('load train journey company=1085, train=7839', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // Verify we have trainnumber with 7839.
      expect(find.text('7839'), findsOneWidget);

      // Verify we have ru SBB.
      expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

      // check that the primary button is enabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      // press load Fahrordnung button
      await tester.tap(primaryButton);

      // wait for train journey to load
      await tester.pumpAndSettle();

      // check if station is present
      expect(find.text('Solothurn'), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('show the correct next stop', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // check that the primary button is enabled
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;

      // press load Fahrordnung button
      await tester.tap(primaryButton);

      // wait for train journey to load
      await tester.pumpAndSettle();

      // check if station is present more than once
      expect(find.text('Lommiswil'), findsNWidgets(2));

      await tester.pumpAndSettle();
    });
  });
}
