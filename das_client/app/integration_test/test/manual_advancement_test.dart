import 'package:app/pages/journey/journey_screen/header/widgets/journey_advancement_button.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

void main() {
  group('manual advancement tests', () {
    testWidgets('manualAdvancement_whenServicePointDragged_thenJourneyPositionMoved', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9999M');

      // Check chevron at start A
      final a = '(Bahnhof A)';
      expect(find.descendant(of: findDASTableRowByText(a), matching: find.byKey(RouteChevron.chevronKey)), findsAny);

      // set position to B manually
      final b = 'Haltestelle B';
      await tester.drag(findDASTableRowByText(b), const Offset(600, 0));
      await tester.pumpAndSettle();

      // Check chevron at B
      expect(
        find.descendant(of: findDASTableRowByText(b), matching: find.byKey(RouteChevron.chevronKey)),
        findsAny,
      );

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('S1'), scrollableFinder, const Offset(0, 50));

      // check can dismiss drag gesture
      await tester.drag(
        find.descendant(of: find.byKey(StickyHeader.headerKey), matching: find.text(a)),
        const Offset(150, 0),
      );
      await tester.pumpAndSettle();

      // check chevron not at A
      expect(
        find.descendant(
          of: find.descendant(of: find.byKey(StickyHeader.headerKey), matching: find.text(a)),
          matching: find.byKey(RouteChevron.chevronKey),
        ),
        findsNothing,
      );

      // pause mode
      await stopAutomaticAdvancement(tester);

      await tester.drag(
        find.descendant(of: find.byKey(StickyHeader.headerKey), matching: find.text(a)),
        const Offset(600, 0),
      );
      await tester.pumpAndSettle(Duration(seconds: 1));

      expect(
        find.descendant(of: find.byKey(StickyHeader.headerKey), matching: find.byKey(RouteChevron.chevronKey)),
        findsAny,
      );

      await disconnect(tester);
    });

    testWidgets('manualAdvancement_whenManualPositionSet_thenManualModeActivatedUntilJourneyPositionSignaled', (
      tester,
    ) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T30');

      final coppet = 'Coppet';
      // set position to Coppet manually
      await tester.drag(findDASTableRowByText(coppet), const Offset(600, 0));

      // check manual mode
      await waitUntilExists(
        tester,
        find.descendant(
          of: find.byKey(JourneyAdvancementButton.pauseKey),
          matching: find.byIcon(SBBIcons.hand_cursor_small),
        ),
      );

      // Check chevron at B
      await waitUntilExists(
        tester,
        find.descendant(of: findDASTableRowByText(coppet), matching: find.byKey(RouteChevron.chevronKey)),
      );

      // wait until signal received and back to non manual mode
      await waitUntilExists(
        tester,
        find.descendant(of: find.byKey(JourneyAdvancementButton.pauseKey), matching: find.byIcon(SBBIcons.pause_small)),
      );

      await disconnect(tester);
    });

    testWidgets('manualAdvancement_whenManualPositionSet_thenStartTimedAdvancement', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T46M');

      await stopAutomaticAdvancement(tester);

      // Wait for 10 seconds so timed advancement is finished
      await Future.delayed(const Duration(seconds: 10));

      final varzo = 'Varzo';
      await tester.drag(findDASTableRowByText(varzo), const Offset(600, 0));

      // Preglia is skipped, because Domodossola (bif) time is before Preglia
      final locations = ['Varzo', 'Domodossola (bif)', 'Domodossola (I)'];

      for (final location in locations) {
        await waitUntilExists(
          tester,
          find.descendant(of: findDASTableRowByText(location), matching: find.byKey(RouteChevron.chevronKey)),
        );
      }

      await disconnect(tester);
    });

    testWidgets('manualAdvancement_whenManualPositionSet_thenRestartsPositionTimers', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T46M');

      await stopAutomaticAdvancement(tester);

      final domodossola = 'Domodossola (bif)';
      await tester.drag(findDASTableRowByText(domodossola), const Offset(600, 0));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 6));

      await tester.drag(findDASTableRowByText(domodossola), const Offset(600, 0));
      await tester.pumpAndSettle();

      await Future.delayed(const Duration(seconds: 6));

      // Chevron should still be at Domodossola (bif) because the timer was restarted
      expect(
        find.descendant(of: findDASTableRowByText(domodossola), matching: find.byKey(RouteChevron.chevronKey)),
        findsOne,
      );

      await waitUntilExists(
        tester,
        find.descendant(of: findDASTableRowByText('Domodossola (I)'), matching: find.byKey(RouteChevron.chevronKey)),
      );

      await disconnect(tester);
    });
  });
}
