import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cab_signaling_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/curve_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/protection_section_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/signal_row.dart';
import 'package:das_client/app/pages/profile/profile_page.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey table test', () {
    testWidgets('test connection track is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final weicheRow = findDASTableRowByText('Weiche');
      expect(weicheRow, findsOneWidget);

      final weicheKilometre = find.descendant(of: weicheRow, matching: find.text('0.8'));
      expect(weicheKilometre, findsOneWidget);

      await tester.dragUntilVisible(find.text('AnG. WITZ'), scrollableFinder, const Offset(0, -50));

      final connectionTrackRow = findDASTableRowByText('AnG. WITZ');
      expect(connectionTrackRow, findsOneWidget);

      await tester.dragUntilVisible(find.text('22-6 Uhr'), scrollableFinder, const Offset(0, -50));

      final connectionTrackWithSpeedRow = findDASTableRowByText('22-6 Uhr');
      expect(connectionTrackWithSpeedRow, findsOneWidget);

      final speedInformation = find.descendant(of: connectionTrackWithSpeedRow, matching: find.text('45'));
      expect(speedInformation, findsOneWidget);

      await tester.dragUntilVisible(find.text('Zahnstangen Anfang'), scrollableFinder, const Offset(0, -50));

      final zahnstangeAnfangRow = findDASTableRowByText('Zahnstangen Anfang');
      expect(zahnstangeAnfangRow, findsOneWidget);

      await tester.dragUntilVisible(find.text('Zahnstangen Ende'), scrollableFinder, const Offset(0, -50));

      final zahnstangeEndeRow = findDASTableRowByText('Zahnstangen Ende');
      expect(zahnstangeEndeRow, findsOneWidget);
    });

    testWidgets('test additional speed restriction row is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '500');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final asrRow = findDASTableRowByText('km 64.200 - km 47.200');
      expect(asrRow, findsOneWidget);

      final asrIcon = find.descendant(
          of: asrRow, matching: find.byKey(AdditionalSpeedRestrictionRow.additionalSpeedRestrictionIconKey));
      expect(asrIcon, findsOneWidget);

      final asrSpeed = find.descendant(of: asrRow, matching: find.text('60'));
      expect(asrSpeed, findsOneWidget);

      // check all cells are colored
      final coloredCells = find.descendant(
          of: asrRow,
          matching: find.byWidgetPredicate((it) =>
              it is Container &&
              it.decoration is BoxDecoration &&
              (it.decoration as BoxDecoration).color == AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor));
      expect(coloredCells, findsNWidgets(11));
    });

    testWidgets('test other rows are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '500');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final testRows = ['Genève', 'km 32.2', 'Lengnau', 'WANZ'];

      for (final rowText in testRows) {
        await tester.dragUntilVisible(find.text(rowText), scrollableFinder, const Offset(0, -50));

        final testRow = findDASTableRowByText(rowText);
        expect(testRow, findsOneWidget);

        // check first 3 cells are colored
        final coloredCells = find.descendant(
            of: testRow,
            matching: find.byWidgetPredicate((it) =>
                it is Container &&
                it.decoration is BoxDecoration &&
                (it.decoration as BoxDecoration).color ==
                    AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor));
        expect(coloredCells, findsNWidgets(3));
      }
    });

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

    testWidgets('test route is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final stopRouteRow = findDASTableRowByText('Bahnhof A');
      final nonStoppingPassRouteRow = findDASTableRowByText('Haltestelle B');
      expect(stopRouteRow, findsOneWidget);
      expect(nonStoppingPassRouteRow, findsOneWidget);

      // check stop circles
      final stopRoute = find.descendant(of: stopRouteRow, matching: find.byKey(RouteCellBody.stopKey));
      final nonStoppingPassRoute =
          find.descendant(of: nonStoppingPassRouteRow, matching: find.byKey(RouteCellBody.stopKey));
      expect(stopRoute, findsOneWidget);
      expect(nonStoppingPassRoute, findsNothing);

      // check route start
      final routeStart = find.byKey(RouteCellBody.routeStartKey);
      expect(routeStart, findsOneWidget);

      await tester.dragUntilVisible(find.byKey(RouteCellBody.routeEndKey), scrollableFinder, const Offset(0, -50));

      // check route end
      final routeEnd = find.byKey(RouteCellBody.routeEndKey);
      expect(routeEnd, findsOneWidget);
    });

    testWidgets('test protection sections are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '513');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      // check first train station
      expect(find.text('Genève-Aéroport'), findsOneWidget);

      // Scroll to first protection section
      await tester.dragUntilVisible(find.text('Gilly-Bursinel'), scrollableFinder, const Offset(0, -20));

      var protectionSectionRow = findDASTableRowByText('km 32.2');
      expect(protectionSectionRow, findsOneWidget);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('FL')), findsOneWidget);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('32.2')), findsOneWidget);
      // Verify icon is displayed
      expect(find.descendant(of: protectionSectionRow, matching: find.byKey(ProtectionSectionRow.protectionSectionKey)),
          findsOneWidget);

      // Scroll to next protection section
      await tester.dragUntilVisible(find.text('Yverdon-les-Bains'), scrollableFinder, const Offset(0, -20));
      await tester.pumpAndSettle();

      protectionSectionRow = findDASTableRowByText('km 45.8');
      expect(protectionSectionRow, findsOneWidget);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('L')), findsOneWidget);

      // Scroll to next protection section
      await tester.dragUntilVisible(find.text('Lengnau'), scrollableFinder, const Offset(0, -20));
      await tester.pumpAndSettle();

      protectionSectionRow = findDASTableRowByText('km 86.7');
      expect(protectionSectionRow, findsOneWidget);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('FL')), findsOneWidget);

      // Scroll to next protection section
      await tester.dragUntilVisible(find.text('WANZ'), scrollableFinder, const Offset(0, -20));
      await tester.pumpAndSettle();

      protectionSectionRow = findDASTableRowByText('km 45.9');
      expect(protectionSectionRow, findsOneWidget);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('FL')), findsOneWidget);

      // Scroll to next protection section
      await tester.dragUntilVisible(find.text('Mellingen Heitersberg'), scrollableFinder, const Offset(0, -20));
      await tester.pumpAndSettle();

      protectionSectionRow = findDASTableRowByText('km 21.5');
      expect(protectionSectionRow, findsOneWidget);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('F')), findsOneWidget);

      // Scroll to next protection section
      await tester.dragUntilVisible(find.text('Flughafen'), scrollableFinder, const Offset(0, -20));
      await tester.pumpAndSettle();

      protectionSectionRow = findDASTableRowByText('km 6.6');
      expect(find.descendant(of: protectionSectionRow, matching: find.text('FL')), findsNothing);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('F')), findsNothing);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('L')), findsNothing);
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

    testWidgets('test if train journey stays loaded after navigation', (tester) async {
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

    testWidgets('test bracket stations is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('Klammerbahnhof D1'), scrollableFinder, const Offset(0, -50));

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

    testWidgets('test halt on request is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('Halt auf Verlangen C'), scrollableFinder, const Offset(0, -50));

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

    testWidgets('test curves are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('Kurve').first, scrollableFinder, const Offset(0, -50));

      final curveRows = findDASTableRowByText('Kurve');
      expect(curveRows, findsAtLeast(1));

      final curveIcon = find.descendant(of: curveRows.first, matching: find.byKey(CurvePointRow.curvePointIconKey));
      expect(curveIcon, findsOneWidget);

      await tester.dragUntilVisible(find.text('Kurve nach Haltestelle'), scrollableFinder, const Offset(0, -50));

      final curveAfterHaltRow = findDASTableRowByText('Kurve nach Haltestelle');
      expect(curveAfterHaltRow, findsOneWidget);
    });

    testWidgets('test signals are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      // check if signals with both functions laneChange, block are correct
      await tester.dragUntilVisible(find.text('S1'), scrollableFinder, const Offset(0, -50));
      final langeChangeBlockSignalRow = findDASTableRowByText('S1');
      expect(langeChangeBlockSignalRow, findsOneWidget);
      expect(find.descendant(of: langeChangeBlockSignalRow, matching: find.text('Block')), findsOneWidget);
      final laneChangeIcon =
          find.descendant(of: langeChangeBlockSignalRow, matching: find.byKey(SignalRow.signalLineChangeIconKey));
      expect(laneChangeIcon, findsOneWidget);

      // check if basic signal is rendered correctly
      await tester.dragUntilVisible(find.text('Deckungssignal'), scrollableFinder, const Offset(0, -50));
      final protectionSignalRow = findDASTableRowByText('Deckungssignal');
      expect(protectionSignalRow, findsOneWidget);
      expect(find.descendant(of: protectionSignalRow, matching: find.text('D1')), findsOneWidget);
      final noLaneChangeIcon =
          find.descendant(of: protectionSignalRow, matching: find.byKey(SignalRow.signalLineChangeIconKey));
      expect(noLaneChangeIcon, findsNothing);

      // check if signals with multiple functions are rendered correctly
      await tester.dragUntilVisible(find.text('Block/Abschnittsignal'), scrollableFinder, const Offset(0, -50));
      final blockIntermediateSignalRow = findDASTableRowByText('Block/Abschnittsignal');
      expect(blockIntermediateSignalRow, findsOneWidget);
      expect(find.descendant(of: blockIntermediateSignalRow, matching: find.text('BAB1')), findsOneWidget);
      final noLaneChangeIcon2 =
          find.descendant(of: blockIntermediateSignalRow, matching: find.byKey(SignalRow.signalLineChangeIconKey));
      expect(noLaneChangeIcon2, findsNothing);
    });

    testWidgets('test if CAB signaling is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: '9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      // CAB segment with start outside train journey and end at 0.6 km
      await tester.dragUntilVisible(find.text('0.6').first, scrollableFinder, const Offset(0, -50));
      final segment1CABStop = findDASTableRowByText('0.6').first;
      final segment1CABStopIcon = find.descendant(of: segment1CABStop, matching: find.byKey(CABSignalingRow.cabSignalingEndIconKey));
      expect(segment1CABStopIcon, findsOneWidget);

      // CAB segment from km 1.1 to 1.5
      await tester.dragUntilVisible(find.text('1.1'), scrollableFinder, const Offset(0, -50));
      final segment2CABStart = findDASTableRowByText('1.1');
      final segment2CABStartIcon = find.descendant(of: segment2CABStart, matching: find.byKey(CABSignalingRow.cabSignalingStartIconKey));
      expect(segment2CABStartIcon, findsOneWidget);
      await tester.dragUntilVisible(find.text('1.7'), scrollableFinder, const Offset(0, -50));
      final segment2CABStop = findDASTableRowByText('1.5').last;
      final segment2CABStopIcon = find.descendant(of: segment2CABStop, matching: find.byKey(CABSignalingRow.cabSignalingEndIconKey));
      expect(segment2CABStopIcon, findsOneWidget);

      // CAB segment from km 1.7 to 3.5
      await tester.dragUntilVisible(find.text('1.8'), scrollableFinder, const Offset(0, -50));
      final segment3CABStart = findDASTableRowByText('1.7').first;
      final segment3CABStartIcon = find.descendant(of: segment3CABStart, matching: find.byKey(CABSignalingRow.cabSignalingStartIconKey));
      expect(segment3CABStartIcon, findsOneWidget);
      await tester.dragUntilVisible(find.text('3.7'), scrollableFinder, const Offset(0, -50));
      final segment3CABStop = findDASTableRowByText('3.5').last;
      final segment3CABStopIcon = find.descendant(of: segment3CABStop, matching: find.byKey(CABSignalingRow.cabSignalingEndIconKey));
      expect(segment3CABStopIcon, findsOneWidget);

      // CAB segment from km 0.6 to 0.9
      await tester.dragUntilVisible(find.text('BAB1'), scrollableFinder, const Offset(0, -50));
      final segment4CABStart = findDASTableRowByText('0.6').first;
      final segment4CABStartIcon = find.descendant(of: segment4CABStart, matching: find.byKey(CABSignalingRow.cabSignalingStartIconKey));
      expect(segment4CABStartIcon, findsOneWidget);
      final segment4CABStop = findDASTableRowByText('0.9').last;
      final segment4CABStopIcon = find.descendant(of: segment4CABStop, matching: find.byKey(CABSignalingRow.cabSignalingEndIconKey));
      expect(segment4CABStopIcon, findsOneWidget);

      // CAB segment with end outside train journey and start at 1.0 km
      await tester.dragUntilVisible(find.text('1.0'), scrollableFinder, const Offset(0, -50));
      final segment5CABStart = findDASTableRowByText('1.0').first;
      final segment5CABStartIcon = find.descendant(of: segment5CABStart, matching: find.byKey(CABSignalingRow.cabSignalingStartIconKey));
      expect(segment5CABStartIcon, findsOneWidget);
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
