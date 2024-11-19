import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/pages/profile/profile_page.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey table test', () {
    testWidgets('check if all table columns with header are present', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816');

      // List of expected column headers
      final List<String> expectedHeaders = [
        l10n.p_train_journey_table_kilometre_label,
        l10n.p_train_journey_table_journey_information_label,
        l10n.p_train_journey_table_time_label,
        l10n.p_train_journey_table_advised_speed_label,
        l10n.p_train_journey_table_braked_weight_speed_label,
        l10n.p_train_journey_table_graduated_speed_label,
      ];

      // Check if each header is present in the widget tree
      for (final header in expectedHeaders) {
        expect(find.text(header), findsOneWidget);
      }
    });

    testWidgets('test scrolling to last train station', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      // check first train station
      expect(find.text('Zürich HB'), findsOneWidget);

      // Scroll to last train station
      await tester.dragUntilVisible(find.text('Aarau'), find.byType(ListView), const Offset(0, -300));
    });

    testWidgets('test fahrbild stays loaded after navigation', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816');

      // check first train station
      expect(find.text('Zürich HB'), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_profile_title));

      // Check on ProfilePage
      expect(find.byType(ProfilePage), findsOneWidget);

      await openDrawer(tester);
      await tapElement(tester, find.text(l10n.w_navigation_drawer_fahrtinfo_title));

      // check first train station is still visible
      expect(find.text('Zürich HB'), findsOneWidget);
    });

    testWidgets('test both kilometres are displayed', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final hardbruckeRow = findDASTableRowByText('Hardbrücke');
      expect(hardbruckeRow, findsOneWidget);
      expect(find.descendant(of: hardbruckeRow, matching: find.text('1.9')), findsOneWidget);
      expect(find.descendant(of: hardbruckeRow, matching: find.text('23.5')), findsOneWidget);
    });

    testWidgets('test bracket stations is displayed correcly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final bracketStationD = findDASTableRowByText('Klammerbahnhof D');
      final bracketStationD1 = findDASTableRowByText('Klammerbahnhof D1');
      expect(bracketStationD, findsOneWidget);
      expect(bracketStationD1, findsOneWidget);

      // check if the bracket station widget is displayed
      final bracketStationDWidget =
          find.descendant(of: bracketStationD, matching: find.byKey(BracketStationBody.bracketStationKey));
      final bracketStationD1Widget =
          find.descendant(of: bracketStationD1, matching: find.byKey(BracketStationBody.bracketStationKey));
      expect(bracketStationDWidget, findsOneWidget);
      expect(bracketStationD1Widget, findsOneWidget);

      // check that the abbreviation is displayed correctly
      expect(find.descendant(of: bracketStationDWidget, matching: find.text('D')), findsNothing);
      expect(find.descendant(of: bracketStationD1Widget, matching: find.text('D')), findsOneWidget);
    });

    testWidgets('test halt on request is displayed correcly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final stopOnDemandRow = findDASTableRowByText('Halt auf Verlangen C');
      expect(stopOnDemandRow, findsOneWidget);

      final stopOnRequestIcon =
          find.descendant(of: stopOnDemandRow, matching: find.byKey(ServicePointRow.stopOnRequestKey));
      expect(stopOnRequestIcon, findsOneWidget);

      final stopOnRequestRoute =
          find.descendant(of: stopOnDemandRow, matching: find.byKey(RouteCellBody.stopOnRequestKey));
      final stopRoute = find.descendant(of: stopOnDemandRow, matching: find.byKey(RouteCellBody.stopKey));
      expect(stopOnRequestRoute, findsOneWidget);
      expect(stopRoute, findsNothing);
    });

    testWidgets('test route is displayed correcly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final stopRouteRow = findDASTableRowByText('Bahnhof A');
      final durchfahrtRoutRow = findDASTableRowByText('Haltestelle B');
      expect(stopRouteRow, findsOneWidget);
      expect(durchfahrtRoutRow, findsOneWidget);

      // check stop circles
      final stopRoute = find.descendant(of: stopRouteRow, matching: find.byKey(RouteCellBody.stopKey));
      final durchFahrtRoute = find.descendant(of: durchfahrtRoutRow, matching: find.byKey(RouteCellBody.stopKey));
      expect(stopRoute, findsOneWidget);
      expect(durchFahrtRoute, findsNothing);

      // check route start
      final startStationRow = findDASTableRowByText('Bahnhof A');
      final routeStart = find.descendant(of: startStationRow, matching: find.byKey(RouteCellBody.routeStartKey));
      expect(routeStart, findsOneWidget);

      // check route end
      final endStationRow = findDASTableRowByText('Klammerbahnhof D1');
      final routeEnd = find.descendant(of: endStationRow, matching: find.byKey(RouteCellBody.routeEndKey));
      expect(routeEnd, findsOneWidget);
    });

    testWidgets('test halt is displayed italic', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '4816');

      final glanzenbergText = find
          .byWidgetPredicate((it) => it is Text && it.data == 'Glanzenberg' && it.style?.fontStyle == FontStyle.italic);
      expect(glanzenbergText, findsOneWidget);

      final schlierenText = find
          .byWidgetPredicate((it) => it is Text && it.data == 'Schlieren' && it.style?.fontStyle != FontStyle.italic);
      expect(schlierenText, findsOneWidget);
    });
  });
}

/// Verifies, that SBB is selected and loads train journey with [trainNumber]
Future<void> _loadTrainJourney(WidgetTester tester, {required String trainNumber}) async {
  // verify we have ru SBB selected.
  expect(find.text(l10n.c_ru_sbb_p), findsOneWidget);

  final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
  expect(trainNumberText, findsOneWidget);

  await enterText(tester, trainNumberText, trainNumber);

  // load train journey
  final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
  await tester.tap(primaryButton);

  // wait for train journey to load
  await tester.pumpAndSettle();
}
