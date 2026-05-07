import 'package:app/pages/journey/journey_screen/header/header.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_advancement_button.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_identifier.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_search_overlay.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/navigation_buttons.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('Journey search overlay tests', () {
    testWidgets('overlay can be opened and dismissed', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T1');

      // closed by default - should show journeySearch icon with key
      expect(find.byKey(JourneySearchOverlay.journeySearchWidgetKey), findsOneWidget);
      expect(find.byKey(JourneySearchOverlay.journeySearchCloseKey), findsNothing);

      // open
      await _openJourneySearchOverlayByTap(tester);

      // opened
      expect(find.byKey(JourneySearchOverlay.journeySearchCloseKey), findsAny);

      // close
      await _closeJourneySearchOverlayByTap(tester);

      // closed
      expect(find.byKey(JourneySearchOverlay.journeySearchWidgetKey), findsOneWidget);
      expect(find.byKey(JourneySearchOverlay.journeySearchCloseKey), findsNothing);

      await disconnect(tester);
    });

    testWidgets('input fields have defaults and validation works', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T1');
      final journeySearchOverlay = find.byType(JourneySearchOverlay);

      // open
      await _openJourneySearchOverlayByTap(tester);

      // Verify we have ru SBB.
      expect(find.descendant(of: journeySearchOverlay, matching: find.text(l10n.c_ru_sbb_p)), findsOneWidget);

      // Verify that today is preselected
      expect(
        find.descendant(of: journeySearchOverlay, matching: find.text(Format.date(DateTime.now()))),
        findsOneWidget,
      );

      // check that the primary button is disabled
      final primaryButton = find.descendant(
        of: journeySearchOverlay,
        matching: find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first,
      );
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNull);

      // set input
      final trainNumberText = findTextInputByPlaceholder(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);
      await enterText(tester, trainNumberText, '123');

      // button enabled
      expect(tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await disconnect(tester);
    });

    testWidgets('loading another train journey work and should not display navigation buttons', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T1');
      final journeySearchOverlay = find.byType(JourneySearchOverlay);

      // open
      await _openJourneySearchOverlayByTap(tester);

      // set input
      final trainNumberText = findTextInputByPlaceholder(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);
      await enterText(tester, trainNumberText, 'T2');

      // load T2 Journey
      final primaryButton = find.descendant(
        of: journeySearchOverlay,
        matching: find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first,
      );
      await tapElement(tester, primaryButton);

      // wait until T2 opened
      await waitUntilExists(
        tester,
        find.descendant(of: find.byType(Header), matching: find.text('T2 ${l10n.c_ru_sbb_p}')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationButtons), findsNothing);

      // pause auto advancement
      final pauseButton = find.byKey(JourneyAdvancementButton.pauseKey);
      await tapElement(tester, pauseButton);
      await tester.pumpAndSettle(Duration(milliseconds: 300));

      // navigation buttons still not displayed
      expect(find.byType(NavigationButtons), findsNothing);

      await disconnect(tester);
    });
  });
}

Future<void> _openJourneySearchOverlayByTap(WidgetTester tester) async {
  final journeyIdentifier = find.descendant(
    of: find.byType(JourneySearchOverlay),
    matching: find.byKey(JourneyIdentifier.journeyIdentifierKey),
  );
  await tapElement(tester, journeyIdentifier, warnIfMissed: false);
  await Future.delayed(const Duration(milliseconds: 250));
}

Future<void> _closeJourneySearchOverlayByTap(WidgetTester tester) async {
  final icon = find.descendant(of: find.byType(JourneySearchOverlay), matching: find.byIcon(SBBIcons.cross_small));
  await tapElement(tester, icon, warnIfMissed: false);
  await Future.delayed(const Duration(milliseconds: 250));
}
