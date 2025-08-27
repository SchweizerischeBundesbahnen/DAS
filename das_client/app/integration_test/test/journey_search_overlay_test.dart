import 'package:app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:app/pages/journey/train_journey/widgets/header/journey_search_overlay.dart';
import 'package:app/pages/journey/train_journey/widgets/header/start_pause_button.dart';
import 'package:app/pages/journey/train_journey/widgets/journey_navigation_buttons.dart';
import 'package:app/util/format.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('Journey search overlay tests', () {
    patrolTest('overlay can be opened and dismissed', (tester) async {
      await prepareAndStartApp(tester.tester);
      await loadTrainJourney(tester.tester, trainNumber: 'T1');

      // closed by default - should show journeySearch icon with key
      expect(find.byKey(JourneySearchOverlay.journeySearchKey), findsOneWidget);
      expect(find.byKey(JourneySearchOverlay.journeySearchCloseKey), findsNothing);

      // open
      await _openJourneySearchOverlayByTap(tester.tester);

      // opened
      expect(find.byKey(JourneySearchOverlay.journeySearchCloseKey), findsAny);

      // close
      await _closeJourneySearchOverlayByTap(tester.tester);

      // closed
      expect(find.byKey(JourneySearchOverlay.journeySearchKey), findsOneWidget);
      expect(find.byKey(JourneySearchOverlay.journeySearchCloseKey), findsNothing);

      await disconnect(tester.tester);
    });

    patrolTest('input fields have defaults and validation works', (tester) async {
      await prepareAndStartApp(tester.tester);
      await loadTrainJourney(tester.tester, trainNumber: 'T1');
      final journeySearchOverlay = find.byType(JourneySearchOverlay);

      // open
      await _openJourneySearchOverlayByTap(tester.tester);

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
      expect(tester.tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNull);

      // set input
      final trainNumberText = findTextFieldByHint(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);
      await enterText(tester.tester, trainNumberText, '123');

      // button enabled
      expect(tester.tester.widget<SBBPrimaryButton>(primaryButton).onPressed, isNotNull);

      await disconnect(tester.tester);
    });

    patrolTest('loading another train journey and displaying navigation buttons work', (tester) async {
      await prepareAndStartApp(tester.tester);
      await loadTrainJourney(tester.tester, trainNumber: 'T1');
      final journeySearchOverlay = find.byType(JourneySearchOverlay);

      // open
      await _openJourneySearchOverlayByTap(tester.tester);

      // set input
      final trainNumberText = findTextFieldByHint(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);
      await enterText(tester.tester, trainNumberText, 'T2');

      // load T2 Journey
      final primaryButton = find.descendant(
        of: journeySearchOverlay,
        matching: find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first,
      );
      await tapElement(tester.tester, primaryButton);

      // wait until T2 opened
      await waitUntilExists(tester.tester, find.descendant(of: find.byType(Header), matching: find.text('T2 SBB')));
      await tester.tester.pumpAndSettle();

      // should not display navigation buttons (autoAdvancement is active)
      final opacity = find.descendant(
        of: find.byType(JourneyNavigationButtons),
        matching: find.byType(AnimatedOpacity),
      );
      expect(tester.tester.widget<AnimatedOpacity>(opacity).opacity, isZero);

      // pause auto advancement
      final pauseButton = find.byKey(StartPauseButton.pauseButtonKey);
      await tapElement(tester.tester, pauseButton);
      await tester.tester.pumpAndSettle(Duration(milliseconds: 300));

      // navigation buttons displayed
      expect(tester.tester.widget<AnimatedOpacity>(opacity).opacity, isNonZero);

      // navigate to previous journey
      final previousButton = find.byKey(JourneyNavigationButtons.journeyNavigationButtonPreviousKey);
      await tapElement(tester.tester, previousButton);

      // wait until T1 opened
      await waitUntilExists(tester.tester, find.descendant(of: find.byType(Header), matching: find.text('T1 SBB')));

      await disconnect(tester.tester);
    });
  });
}

Future<void> _openJourneySearchOverlayByTap(WidgetTester tester) async {
  final icon = find.descendant(
    of: find.byType(JourneySearchOverlay),
    matching: find.byIcon(SBBIcons.magnifying_glass_small),
  );
  await tapElement(tester, icon, warnIfMissed: false);
  await Future.delayed(const Duration(milliseconds: 250));
}

Future<void> _closeJourneySearchOverlayByTap(WidgetTester tester) async {
  final icon = find.descendant(of: find.byType(JourneySearchOverlay), matching: find.byIcon(SBBIcons.cross_small));
  await tapElement(tester, icon, warnIfMissed: false);
  await Future.delayed(const Duration(milliseconds: 250));
}
