import 'package:app/di/di.dart';
import 'package:app/pages/journey/journey_screen/header/header.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/journey_advancement_button.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/util/time_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

void main() {
  group('automatic advancement tests', () {
    testWidgets('automaticAdvancement_whenJourneyLoaded_thenScrollsAutomatically|tests:94', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9');

      // Check journey position at journey start
      expect(findChevronPositionAtRowWithText('Bern'), findsAny);

      final locations = ['B2', 'B3', 'Burgdorf', 'B101', 'A104'];

      for (final location in locations) {
        await waitUntilExists(tester, findChevronPositionAtRowWithText(location));
      }

      await disconnect(tester);
    });

    testWidgets('automaticAdvancement_whenIdleTimeReached_thenScrollsBackToPosition|tests:94', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9');

      // Wait until all events are done
      await Future.delayed(const Duration(seconds: 12));

      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('B1'), scrollableFinder, const Offset(0, 100));
      expect(find.text('Bern'), findsAny);

      final waitTime = DI.get<TimeConstants>().automaticAdvancementIdleTimeAutoScroll + 1;

      // wait until waitTime reached
      await Future.delayed(Duration(seconds: waitTime));
      await tester.pumpAndSettle();

      // Check if the last row is visible
      expect(findDASTableRowByText('Olten'), findsAny);

      await disconnect(tester);
    });

    testWidgets('automaticAdvancement_whenReEnabled_thenScrollsToCurrentPosition|tests:94', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9');

      await stopAutomaticAdvancement(tester);

      // Wait until the chevron is no longer visible
      await waitUntilNotExists(tester, find.byKey(RouteChevron.chevronKey), maxWaitSeconds: 40);

      // Wait some more
      await tester.pump(const Duration(seconds: 5));

      await startAutomaticAdvancement(tester);
      // Check if Bern not visible anymore
      expect(findDASTableRowByText('Bern'), findsNothing);

      await disconnect(tester);
    });

    testWidgets('automaticAdvancement_whenDisabled_thenDoesNotScroll|tests:94', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9');

      await stopAutomaticAdvancement(tester);

      // Check journey position at journey start
      expect(findChevronPositionAtRowWithText('Bern'), findsAny);

      // Wait until the chevron is no longer visible
      await waitUntilNotExists(tester, find.byKey(RouteChevron.chevronKey), maxWaitSeconds: 40);

      // Check Bern and B1 still visible
      expect(findDASTableRowByText('Bern'), findsAny);
      expect(findDASTableRowByText('B1'), findsAny);

      await disconnect(tester);
    });

    testWidgets('automaticAdvancement_whenJourneyLoaded_thenIsEnabledByDefault|tests:94', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9');

      // Find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      await stopAutomaticAdvancement(tester);

      expect(
        find.descendant(of: headerFinder, matching: find.byKey(JourneyAdvancementButton.startKey)),
        findsOneWidget,
      );
      expect(find.descendant(of: headerFinder, matching: find.byKey(JourneyAdvancementButton.pauseKey)), findsNothing);

      await disconnect(tester);
    });

    testWidgets('automaticAdvancement_whenDisabled_thenShowsStickyFooter|tests:94', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T9');

      await stopAutomaticAdvancement(tester);

      // Check Bern & Bern Wankdorf are displayed
      expect(findDASTableRowByText('Bern'), findsAny);
      expect(find.text('Bern Wankdorf'), findsAny);

      await disconnect(tester);
    });
  });

  group('timed advancement tests', () {
    testWidgets('timedAdvancement_whenJourneyLoaded_thenAdvancesCorrectly|tests:1419', (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T46M');

      // Check journey position at journey start
      expect(findChevronPositionAtRowWithText('Iselle'), findsAny);

      // Preglia is skipped, because Domodossola (bif) time is before Preglia
      final locations = ['Varzo', 'Domodossola (bif)', 'Domodossola (I)'];

      for (final location in locations) {
        await waitUntilExists(tester, findChevronPositionAtRowWithText(location));
      }

      await disconnect(tester);
    });
  });
}
