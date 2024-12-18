import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

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

      //
      final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, '4816');

      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      await tester.tap(primaryButton);

      // wait for train journey to load
      await tester.pumpAndSettle();

      //find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      //Find the text in the header
      expect(find.descendant(of: headerFinder, matching: find.text('Hardbrücke')), findsOneWidget);

      await tester.pumpAndSettle();
    });
  });
}
