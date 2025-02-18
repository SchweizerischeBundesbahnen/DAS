import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_chevron.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('automatic advancement tests', () {
    /*
    testWidgets('check if automatic advancement is scrolling automatically', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      // Check chevron at start
      expect(
          find.descendant(of: findDASTableRowByText('Bern'), matching: find.byKey(RouteChevron.chevronKey)), findsAny);

      final locations = ['B2', 'Burgdorf', 'B101', 'Olten'];

      for (final location in locations) {
        await waitUntilExists(tester,
            find.descendant(of: findDASTableRowByText(location), matching: find.byKey(RouteChevron.chevronKey)));
      }
    });

    testWidgets('check scrolling after idle time', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      // Wait until all events are done
      await Future.delayed(const Duration(seconds: 12));

      await tester.pumpAndSettle();

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('B1'), scrollableFinder, const Offset(0, 100));
      expect(findDASTableRowByText('Bern'), findsAny);

      // Wait until idle time reached
      await Future.delayed(const Duration(seconds: 12));
      await tester.pumpAndSettle();

      // Check if the last row is visible
      expect(findDASTableRowByText('Olten'), findsAny);
    });
    */

    testWidgets('check scrolling to position if automatic scrolling gets enabled', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      final pauseButton = find.text(l10n.p_train_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      // Wait until the chevron is no longer visible
      await waitUntilNotExists(tester, find.byKey(RouteChevron.chevronKey));

      // Wait some more
      await Future.delayed(const Duration(seconds: 3));

      final startButton = find.text(l10n.p_train_journey_header_button_start);
      expect(startButton, findsOneWidget);

      await tapElement(tester, startButton);

      // Check if last row is visible
      expect(findDASTableRowByText('Olten'), findsAny);
    });

    /*

    testWidgets('check not scrolling if automatic advancement is off', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      final pauseButton = find.text(l10n.p_train_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      // Check chevron at start
      expect(
          find.descendant(of: findDASTableRowByText('Bern'), matching: find.byKey(RouteChevron.chevronKey)), findsAny);

      // Wait until the chevron is no longer visible
      await waitUntilNotExists(tester, find.byKey(RouteChevron.chevronKey));

      // Check Bern and B1 still visible
      expect(findDASTableRowByText('Bern'), findsAny);
      expect(findDASTableRowByText('B1'), findsAny);
    });



    testWidgets('check if automatic advancement is enabled by default', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      // Find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      final pauseButton =
          find.descendant(of: headerFinder, matching: find.text(l10n.p_train_journey_header_button_pause));
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      expect(find.descendant(of: headerFinder, matching: find.text(l10n.p_train_journey_header_button_start)),
          findsOneWidget);
      expect(find.descendant(of: headerFinder, matching: find.text(l10n.p_train_journey_header_button_pause)),
          findsNothing);
    });



    testWidgets('check sticky footer is displayed', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9');

      final pauseButton = find.text(l10n.p_train_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      // Check Bern & Burgdorf are displayed
      expect(findDASTableRowByText('Bern'), findsAny);
      expect(find.text('Burgdorf'), findsAny);
    });

   */
  });
}
