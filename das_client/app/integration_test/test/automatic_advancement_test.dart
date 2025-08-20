import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:app/pages/journey/train_journey/widgets/header/start_pause_button.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_chevron.dart';
import 'package:app/util/time_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('automatic advancement tests', () {
    testWidgets('check if automatic advancement is scrolling automatically', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      // Check chevron at start
      expect(
        find.descendant(of: findDASTableRowByText('Bern'), matching: find.byKey(RouteChevron.chevronKey)),
        findsAny,
      );

      final locations = ['B2', 'B3', 'Burgdorf', 'B101', 'Olten'];

      for (final location in locations) {
        await waitUntilExists(
          tester,
          find.descendant(of: findDASTableRowByText(location), matching: find.byKey(RouteChevron.chevronKey)),
        );
      }

      await disconnect(tester);
    });

    testWidgets('check scrolling after idle time', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

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

    testWidgets('check scrolling to position if automatic scrolling gets enabled', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      await toggleAutomaticAdvancement(tester);

      // Wait until the chevron is no longer visible
      await waitUntilNotExists(tester, find.byKey(RouteChevron.chevronKey), maxWaitSeconds: 40);

      // Wait some more
      await Future.delayed(const Duration(seconds: 3));

      final startButton = find.byKey(StartPauseButton.startButtonKey);
      expect(startButton, findsOneWidget);

      await tapElement(tester, startButton);

      // Check if last row is visible
      expect(findDASTableRowByText('Olten'), findsAny);

      await disconnect(tester);
    });

    testWidgets('check not scrolling if automatic advancement is off', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      final pauseButton = find.byKey(StartPauseButton.pauseButtonKey);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      // Check chevron at start
      expect(
        find.descendant(of: findDASTableRowByText('Bern'), matching: find.byKey(RouteChevron.chevronKey)),
        findsAny,
      );

      // Wait until the chevron is no longer visible
      await waitUntilNotExists(tester, find.byKey(RouteChevron.chevronKey), maxWaitSeconds: 40);

      // Check Bern and B1 still visible
      expect(findDASTableRowByText('Bern'), findsAny);
      expect(findDASTableRowByText('B1'), findsAny);

      await disconnect(tester);
    });

    testWidgets('check if automatic advancement is enabled by default', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      // Find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      final pauseButton = find.descendant(of: headerFinder, matching: find.byKey(StartPauseButton.pauseButtonKey));
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      expect(find.descendant(of: headerFinder, matching: find.byKey(StartPauseButton.startButtonKey)), findsOneWidget);
      expect(find.descendant(of: headerFinder, matching: find.byKey(StartPauseButton.pauseButtonKey)), findsNothing);

      await disconnect(tester);
    });

    testWidgets('check sticky footer is displayed', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      final pauseButton = find.byKey(StartPauseButton.pauseButtonKey);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      // Check Bern & Burgdorf are displayed
      expect(findDASTableRowByText('Bern'), findsAny);
      expect(find.text('Burgdorf'), findsAny);

      await disconnect(tester);
    });
  });
}
