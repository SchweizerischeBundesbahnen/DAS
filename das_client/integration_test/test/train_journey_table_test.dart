import 'dart:async';

import 'package:battery_plus/battery_plus.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/balise_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cab_signaling_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/bracket_station_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/graduated_speeds_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/curve_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/protection_section_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/signal_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/tram_area_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/whistle_row.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:das_client/app/pages/profile/profile_page.dart';
import 'package:das_client/app/widgets/table/das_table.dart';
import 'package:das_client/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../mocks/battery_mock.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey table test', () {

    testWidgets('test battery over 30% and not show icon', (tester) async {
      await prepareAndStartApp(tester);

      final battery = DI.get<Battery>() as BatteryMock;

      battery.currentBatteryLevel = 80;

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T7');

      // Find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      expect(battery.currentBatteryLevel, 80);

      final iconPlace = find.byKey(Key('battery_status_low_key'));
      expect(iconPlace, findsNothing);
    });

    testWidgets('test battery under 30% and show icon', (tester) async {
      await prepareAndStartApp(tester);

      final battery = DI.get<Battery>() as BatteryMock;

      battery.currentBatteryLevel = 15;

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T7');

      // Find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      expect(battery.currentBatteryLevel, 15);

      final iconPlace = find.byKey(Key('battery_status_low_key'));
      expect(iconPlace, findsOneWidget);
    });

    testWidgets('check if update sent is correct', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      // Select the correct train number
      final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, 'T9999');

      // Log into the journey
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      await tester.tap(primaryButton);

      // Wait for train journey to load
      await tester.pumpAndSettle();

      // Find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      // Timer logic: increase timer every second, rerun the base every 100 ms and check if the UI changed
      int counter = 0;

      final completer = Completer<void>();

      expect(find.descendant(of: headerFinder, matching: find.text('+00:00')), findsOneWidget);

      while (!completer.isCompleted) {
        await tester.pumpAndSettle();

        if (!find.descendant(of: headerFinder, matching: find.text('+00:00')).evaluate().isNotEmpty) {
          expect(find.descendant(of: headerFinder, matching: find.text('+00:30')), findsOneWidget);
          completer.complete();
          break;
        }

        // cancel after 10 seconds
        if (counter++ > 10 * 10) {
          completer
              .completeError(Exception('UI did not change from the base value to the updated value (+00:00 -> +00:30)'));
          break;
        }

        await Future.delayed(const Duration(milliseconds: 100));
      }

      await completer.future;

      await tester.pumpAndSettle();
    });

    testWidgets('test balise multiple level crossings', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T7');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final baliseMultiLevelCrossing = findDASTableRowByText('(2 ${l10n.p_train_journey_table_level_crossing})');
      expect(baliseMultiLevelCrossing, findsOneWidget);

      final baliseIcon = find.descendant(of: baliseMultiLevelCrossing, matching: find.byKey(BaliseRow.baliseIconKey));
      expect(baliseIcon, findsOneWidget);
    });

    testWidgets('test whistle and tram area', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T7');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final whistleRow = findDASTableRowByText('39.6');
      expect(whistleRow, findsOneWidget);

      final whistleIcon = find.descendant(of: whistleRow, matching: find.byKey(WhistleRow.whistleIconKey));
      expect(whistleIcon, findsOneWidget);

      final tramAreaRow = findDASTableRowByText('km 37.8-36.8');
      expect(tramAreaRow, findsOneWidget);

      final tramAreaIcon = find.descendant(of: tramAreaRow, matching: find.byKey(TramAreaRow.tramAreaIconKey));
      expect(tramAreaIcon, findsOneWidget);

      final tramAreaDescription = find.descendant(of: tramAreaRow, matching: find.text('6 TS'));
      expect(tramAreaDescription, findsOneWidget);
    });

    testWidgets('test balise and level crossing groups expand / collapse', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T7');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final groupOf5BaliseRow = findDASTableRowByText('41.6');
      expect(groupOf5BaliseRow, findsOneWidget);

      final countText = find.descendant(of: groupOf5BaliseRow, matching: find.text('5'));
      expect(countText, findsOneWidget);

      final levelCrossingText =
          find.descendant(of: groupOf5BaliseRow, matching: find.text(l10n.p_train_journey_table_level_crossing));
      expect(levelCrossingText, findsOneWidget);

      var detailRowBalise = findDASTableRowByText('41.552');
      var detailRowLevelCrossing = findDASTableRowByText('41.492');

      expect(detailRowLevelCrossing, findsNothing);
      expect(detailRowBalise, findsNothing);

      // expand group
      await tapElement(tester, groupOf5BaliseRow);

      detailRowBalise = findDASTableRowByText('41.552');
      detailRowLevelCrossing = findDASTableRowByText('41.492');

      expect(detailRowLevelCrossing, findsOneWidget);
      expect(detailRowBalise, findsOneWidget);

      expect(find.descendant(of: detailRowBalise, matching: find.byKey(BaliseRow.baliseIconKey)), findsOneWidget);
      expect(
          find.descendant(of: detailRowLevelCrossing, matching: find.text(l10n.p_train_journey_table_level_crossing)),
          findsOneWidget);

      // collapse group
      await tapElement(tester, groupOf5BaliseRow);

      detailRowBalise = findDASTableRowByText('41.552');
      detailRowLevelCrossing = findDASTableRowByText('41.492');

      expect(detailRowLevelCrossing, findsNothing);
      expect(detailRowBalise, findsNothing);
    });

    testWidgets('test breaking series defaults to ??', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T6');

      final breakingSeriesHeaderCell = find.byKey(TrainJourney.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('??')), findsNWidgets(1));
    });

    testWidgets('test default breaking series is taken from train characteristics (R115)', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T5');

      final breakingSeriesHeaderCell = find.byKey(TrainJourney.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('R115')), findsNWidgets(1));
    });

    testWidgets('test all breakseries options are displayed', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T5');

      // Open break series bottom sheet
      await tapElement(tester, find.byKey(TrainJourney.breakingSeriesHeaderKey));

      final expectedCategories = {'R', 'A', 'D'};

      for (final entry in expectedCategories) {
        expect(find.text(entry), findsOneWidget);
      }

      final expectedOptions = {
        'R105',
        'R115',
        'R125',
        'R135',
        'R150',
        'A50',
        'A60',
        'A65',
        'A70',
        'A75',
        'A80',
        'A85',
        'A95',
        'A105',
        'A115',
        'D30'
      };

      for (final entry in expectedOptions) {
        expect(find.text(entry), findsAtLeast(1));
      }
    });

    testWidgets('test message when no breakseries are defined', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T4');

      // Open break series bottom sheet
      await tapElement(tester, find.byKey(TrainJourney.breakingSeriesHeaderKey));

      expect(find.text(l10n.p_train_journey_break_series_empty), findsOneWidget);
    });

    testWidgets('test speed values of default breakSeries (R115)', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T5');

      final expectedSpeeds = {
        'Genève-Aéroport': '60',
        '65.3': '44', // 1. Curve
        'New Line Speed All': '60',
        'Genève': '60',
        'New Line Speed A Missing': '60',
        '42.5': '44', // 2. Curve
        '40.5': null, // 3. Curve
        'Gland': '60',
      };

      for (final entry in expectedSpeeds.entries) {
        final tableRow = findDASTableRowByText(entry.key);
        expect(tableRow, findsOneWidget);

        if (entry.value != null) {
          final speedText = find.descendant(of: tableRow, matching: find.text(entry.value!));
          expect(speedText, findsOneWidget);
        } else {
          final textWidgets = find.descendant(of: tableRow, matching: find.byWidgetPredicate((it) => it is Text));
          expect(textWidgets, findsNWidgets(2)); // KM and Kurve text widgets
        }
      }
    });

    testWidgets('test speed values of missing break Series', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T5');

      await _selectBreakSeries(tester, breakSeries: 'A85');

      final breakingSeriesHeaderCell = find.byKey(TrainJourney.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('A85')), findsNWidgets(1));

      final expectedSpeeds = {
        'Genève-Aéroport': '90',
        '65.3': '55', // 1. Curve
        'New Line Speed All': '90',
        'Genève': 'XX',
        'New Line Speed A Missing': 'XX',
        '42.5': 'XX', // 2. Curve
        '40.5': null, // 3. Curve
        'Gland': '90',
      };

      for (final entry in expectedSpeeds.entries) {
        final tableRow = findDASTableRowByText(entry.key);
        expect(tableRow, findsOneWidget);

        if (entry.value != null) {
          final speedText = find.descendant(of: tableRow, matching: find.text(entry.value!));
          expect(speedText, findsOneWidget);
        } else {
          final textWidgets = find.descendant(of: tableRow, matching: find.byWidgetPredicate((it) => it is Text));
          expect(textWidgets, findsNWidgets(2)); // KM and Kurve text widgets
        }
      }
    });

    testWidgets('test connection track is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T9999');

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
      await _loadTrainJourney(tester, trainNumber: 'T2');

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
      expect(coloredCells, findsNWidgets(13));
    });

    testWidgets('test other rows are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T2');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final tableFinder = find.byType(DASTable);
      expect(tableFinder, findsOneWidget);

      final testRows = ['Genève', 'km 32.2', 'Lengnau', 'WANZ'];

      // Scroll to the table and search inside it
      for (final rowText in testRows) {
        final rowFinder = find.descendant(of: tableFinder, matching: find.text(rowText));
        await tester.dragUntilVisible(rowFinder, tableFinder, const Offset(0, -50));

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
        expect(coloredCells, findsNWidgets(4));
      }
    });

    testWidgets('check if all table columns with header are present', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T6');

      // List of expected column headers
      final List<String> expectedHeaders = [
        l10n.p_train_journey_table_kilometre_label,
        l10n.p_train_journey_table_journey_information_label,
        l10n.p_train_journey_table_time_label,
        l10n.p_train_journey_table_advised_speed_label,
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
      await _loadTrainJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      final stopRouteRow = findDASTableRowByText('Bahnhof A');
      expect(stopRouteRow, findsOneWidget);

      await tester.dragUntilVisible(findDASTableRowByText('Haltestelle B'), scrollableFinder, const Offset(0, -50));

      final nonStoppingPassRouteRow = findDASTableRowByText('Haltestelle B');
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
      await _loadTrainJourney(tester, trainNumber: 'T3');

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
      await _loadTrainJourney(tester, trainNumber: 'T6');

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
      await _loadTrainJourney(tester, trainNumber: 'T6');

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
      await _loadTrainJourney(tester, trainNumber: 'T6');

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
      await _loadTrainJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('Klammerbahnhof D1'), scrollableFinder, const Offset(0, -50));

      final bracketStationD = findDASTableRowByText('Klammerbahnhof D');
      final zahnstangenEnde = findDASTableRowByText('Zahnstangen Ende');
      final deckungssignal = findDASTableRowByText('Deckungssignal');
      final bracketStationD1 = findDASTableRowByText('Klammerbahnhof D1');
      expect(bracketStationD, findsOneWidget);
      expect(zahnstangenEnde, findsOneWidget);
      expect(deckungssignal, findsOneWidget);
      expect(bracketStationD1, findsOneWidget);

      // check if the bracket station widget is displayed
      final bracketStationDWidget =
          find.descendant(of: bracketStationD, matching: find.byKey(BracketStationCellBody.bracketStationKey));
      final zahnstangenEndeWidget =
          find.descendant(of: zahnstangenEnde, matching: find.byKey(BracketStationCellBody.bracketStationKey));
      final deckungssignalWidget =
          find.descendant(of: deckungssignal, matching: find.byKey(BracketStationCellBody.bracketStationKey));
      final bracketStationD1Widget =
          find.descendant(of: bracketStationD1, matching: find.byKey(BracketStationCellBody.bracketStationKey));
      expect(bracketStationDWidget, findsOneWidget);
      expect(zahnstangenEndeWidget, findsOneWidget);
      expect(deckungssignalWidget, findsOneWidget);
      expect(bracketStationD1Widget, findsOneWidget);

      // check that the abbreviation is displayed correctly
      expect(find.descendant(of: bracketStationDWidget, matching: find.text('D')), findsOneWidget);
      expect(find.descendant(of: zahnstangenEndeWidget, matching: find.text('D')), findsNothing);
      expect(find.descendant(of: deckungssignalWidget, matching: find.text('D')), findsNothing);
      expect(find.descendant(of: bracketStationD1Widget, matching: find.text('D')), findsNothing);
    });

    testWidgets('test halt on request is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('Klammerbahnhof D'), scrollableFinder, const Offset(0, -50));

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
      await _loadTrainJourney(tester, trainNumber: 'T6');

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
      await _loadTrainJourney(tester, trainNumber: 'T9999');

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
      await _loadTrainJourney(tester, trainNumber: 'T9999');

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
      await _loadTrainJourney(tester, trainNumber: 'T1');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      // CAB segment with start outside train journey and end at 33.8 km
      await tester.dragUntilVisible(find.text('29.7').first, scrollableFinder, const Offset(0, -50));
      final rowsAtKm33_8 = findDASTableRowByText('33.8');
      expect(rowsAtKm33_8, findsExactly(2));
      final segment1CABStop = rowsAtKm33_8.last; // end should be after other elements at same location
      final segment1CABStopIcon =
          find.descendant(of: segment1CABStop, matching: find.byKey(CABSignalingRow.cabSignalingEndIconKey));
      expect(segment1CABStopIcon, findsOneWidget);

      // Track equipment segment without ETCS level 2 should be ignored
      await tester.dragUntilVisible(find.text('12.5').first, scrollableFinder, const Offset(0, -50));
      final etcsL1LSEnd = findDASTableRowByText('10.1');
      expect(etcsL1LSEnd, findsNothing);

      // CAB segment between km 12.5 - km 39.9
      final rowsAtKm12_5 = findDASTableRowByText('12.5');
      expect(rowsAtKm12_5, findsExactly(2));
      final segment2CABStart = rowsAtKm12_5.first; // start should be before other elements at same location
      final segment2CABStartIcon =
          find.descendant(of: segment2CABStart, matching: find.byKey(CABSignalingRow.cabSignalingStartIconKey));
      expect(segment2CABStartIcon, findsOneWidget);
      await tester.dragUntilVisible(find.text('75.3'), scrollableFinder, const Offset(0, -50));
      final trackEquipmentTypeChange = findDASTableRowByText('56.8');
      expect(trackEquipmentTypeChange, findsNothing); // no CAB signaling at connecting ETCS L2 segments
      await tester.dragUntilVisible(find.text('41.5'), scrollableFinder, const Offset(0, -50));
      final rothristServicePointRow = findDASTableRowByText('46.2');
      expect(rothristServicePointRow, findsOneWidget); // no CAB signaling at connecting ETCS L2 segments
      final segment2CABEnd = findDASTableRowByText('39.9');
      final segment2CABEndIcon =
          find.descendant(of: segment2CABEnd, matching: find.byKey(CABSignalingRow.cabSignalingEndIconKey));
      expect(segment2CABEndIcon, findsOneWidget);

      // CAB segment with end outside train journey and start at 8.3 km
      await tester.dragUntilVisible(find.text('9.5'), scrollableFinder, const Offset(0, -50));
      final segment3CABStart = findDASTableRowByText('8.3');
      final segment3CABStartIcon =
          find.descendant(of: segment3CABStart, matching: find.byKey(CABSignalingRow.cabSignalingStartIconKey));
      expect(segment3CABStartIcon, findsOneWidget);
    });

    testWidgets('test if track equipment is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T1');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      // check ExtendedSpeedReversingPossible from Genève-Aéroport to Gland
      _checkTrackEquipmentOnServicePoint('Genève-Aéroport', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
      _checkTrackEquipmentOnServicePoint('Genève', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
      _checkTrackEquipmentOnServicePoint('Gland', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
      final segment1CABStop = findDASTableRowByText('33.8').last;
      final segment1CABStopTrackEquipment = find.descendant(
          of: segment1CABStop, matching: find.byKey(TrackEquipmentCellBody.extendedSpeedReversingPossibleKey));
      expect(segment1CABStopTrackEquipment, findsOneWidget);

      // check two tracks with single track equipment on Gilly-Bursinel
      _checkTrackEquipmentOnServicePoint('Gilly-Bursinel', TrackEquipmentCellBody.twoTracksWithSingleTrackEquipmentKey);

      // check ConventionalSpeedReversingImpossible from Morges to Onnens-Bonvillars
      await tester.dragUntilVisible(find.text('Onnens-Bonvillars'), scrollableFinder, const Offset(0, -50));
      final segment2CABStart = findDASTableRowByText('12.5').first;
      final segment2CABStartTrackEquipment = find.descendant(
          of: segment2CABStart, matching: find.byKey(TrackEquipmentCellBody.conventionalSpeedReversingImpossible));
      expect(segment2CABStartTrackEquipment, findsOneWidget);
      _checkTrackEquipmentOnServicePoint('Morges', TrackEquipmentCellBody.conventionalSpeedReversingImpossible);
      _checkTrackEquipmentOnServicePoint(
          'Yverdon-les-Bains', TrackEquipmentCellBody.conventionalSpeedReversingImpossible);
      _checkTrackEquipmentOnServicePoint(
          'Onnens-Bonvillars', TrackEquipmentCellBody.conventionalSpeedReversingImpossible);

      // check ExtendedSpeedReversingPossibleKey from Neuchâtel to Rothrist
      await tester.dragUntilVisible(find.text('Grenchen Süd'), scrollableFinder, const Offset(0, -50));
      _checkTrackEquipmentOnServicePoint('Neuchâtel', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey,
          hasConvExtSpeedBorder: true);
      _checkTrackEquipmentOnServicePoint('Biel/Bienne', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
      _checkTrackEquipmentOnServicePoint('Lengnau', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
      _checkTrackEquipmentOnServicePoint('Grenchen Süd', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
      await tester.dragUntilVisible(find.text('Rothrist'), scrollableFinder, const Offset(0, -50));
      _checkTrackEquipmentOnServicePoint('Solothurn', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
      _checkTrackEquipmentOnServicePoint('WANZ', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
      _checkTrackEquipmentOnServicePoint('Rothrist', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);

      // check ExtendedSpeedReversingPossibleKey in Olten
      await tester.dragUntilVisible(find.text('Aarau'), scrollableFinder, const Offset(0, -50));
      _checkTrackEquipmentOnServicePoint('Olten', TrackEquipmentCellBody.conventionalSpeedReversingImpossible,
          hasConvExtSpeedBorder: true);
      final segment2CABEnd = findDASTableRowByText('39.9').first;
      final segment2CABEndTrackEquipment = find.descendant(
          of: segment2CABEnd, matching: find.byKey(TrackEquipmentCellBody.conventionalSpeedReversingImpossible));
      expect(segment2CABEndTrackEquipment, findsOneWidget);

      // check ExtendedSpeedReversingImpossibleKey from Zürich HB to Opfikon Süd
      await tester.dragUntilVisible(find.text('Flughafen'), scrollableFinder, const Offset(0, -50));
      final segment3CABStart = findDASTableRowByText('8.3').first;
      final segment3CABStartTrackEquipment = find.descendant(
          of: segment3CABStart, matching: find.byKey(TrackEquipmentCellBody.extendedSpeedReversingImpossibleKey));
      expect(segment3CABStartTrackEquipment, findsOneWidget);
      _checkTrackEquipmentOnServicePoint('Zürich HB', TrackEquipmentCellBody.extendedSpeedReversingImpossibleKey);
      _checkTrackEquipmentOnServicePoint('Opfikon Süd', TrackEquipmentCellBody.extendedSpeedReversingImpossibleKey);

      // check ExtendedSpeedReversingImpossibleKey in Flughafen
      _checkTrackEquipmentOnServicePoint('Flughafen', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    });

    testWidgets('test if station speeds are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await _loadTrainJourney(tester, trainNumber: 'T8');

      final scrollableFinder = find.byType(ListView);
      expect(scrollableFinder, findsOneWidget);

      // check station speeds for Bern

      final bernStationRow = findDASTableRowByText('Bern');
      expect(bernStationRow, findsOneWidget);
      final bernIncomingSpeeds =
          find.descendant(of: bernStationRow, matching: find.byKey(GraduatedSpeedsCellBody.incomingSpeedsKey));
      expect(bernIncomingSpeeds, findsNWidgets(2));
      final bernIncomingSpeedsText = find.descendant(of: bernStationRow, matching: find.text('75-70-60'));
      expect(bernIncomingSpeedsText, findsOneWidget);
      final bernOutgoingSpeeds =
          find.descendant(of: bernStationRow, matching: find.byKey(GraduatedSpeedsCellBody.outgoingSpeedsKey));
      expect(bernOutgoingSpeeds, findsNothing);

      // check station speeds for Wankdorf, no station speeds given

      final wankdorfStationRow = findDASTableRowByText('Wankdorf');
      expect(wankdorfStationRow, findsOneWidget);
      final wankdorfIncomingSpeeds =
          find.descendant(of: wankdorfStationRow, matching: find.byKey(GraduatedSpeedsCellBody.incomingSpeedsKey));
      expect(wankdorfIncomingSpeeds, findsNothing);
      final wankdorfOutgoingSpeeds =
          find.descendant(of: wankdorfStationRow, matching: find.byKey(GraduatedSpeedsCellBody.outgoingSpeedsKey));
      expect(wankdorfOutgoingSpeeds, findsNothing);

      // check station speeds for Burgdorf

      final burgdorfStationRow = findDASTableRowByText('Burgdorf');
      expect(burgdorfStationRow, findsOneWidget);
      final burgdorfIncomingSpeeds =
          find.descendant(of: burgdorfStationRow, matching: find.byKey(GraduatedSpeedsCellBody.incomingSpeedsKey));
      expect(burgdorfIncomingSpeeds, findsNWidgets(2));
      final burgdorfIncomingSpeeds75 = find.descendant(of: burgdorfIncomingSpeeds, matching: find.text('75'));
      expect(burgdorfIncomingSpeeds75, findsOneWidget);
      final burgdorfIncomingSpeeds70 = find.descendant(of: burgdorfIncomingSpeeds, matching: find.text('70'));
      expect(burgdorfIncomingSpeeds70, findsOneWidget);
      final burgdorfIncomingSpeeds70Circled =
          find.ancestor(of: burgdorfIncomingSpeeds70, matching: find.byKey(GraduatedSpeedsCellBody.circledSpeedKey));
      expect(burgdorfIncomingSpeeds70Circled, findsOneWidget);
      final burgdorfOutgoingSpeeds =
          find.descendant(of: burgdorfStationRow, matching: find.byKey(GraduatedSpeedsCellBody.outgoingSpeedsKey));
      expect(burgdorfOutgoingSpeeds, findsOneWidget);
      final burgdorfOutgoingSpeeds60 = find.descendant(of: burgdorfOutgoingSpeeds, matching: find.text('60'));
      expect(burgdorfOutgoingSpeeds60, findsOneWidget);
      final burgdorfOutgoingSpeeds60Squared =
          find.ancestor(of: burgdorfOutgoingSpeeds60, matching: find.byKey(GraduatedSpeedsCellBody.squaredSpeedKey));
      expect(burgdorfOutgoingSpeeds60Squared, findsOneWidget);

      // check station speeds for Olten, no graduated speed for train series R

      final oltenStationRow = findDASTableRowByText('Olten');
      expect(oltenStationRow, findsOneWidget);
      final oltenIncomingSpeeds =
          find.descendant(of: oltenStationRow, matching: find.byKey(GraduatedSpeedsCellBody.incomingSpeedsKey));
      expect(oltenIncomingSpeeds, findsOneWidget);
      final oltenOutgoingSpeeds =
          find.descendant(of: oltenStationRow, matching: find.byKey(GraduatedSpeedsCellBody.outgoingSpeedsKey));
      expect(oltenOutgoingSpeeds, findsNothing);

    });

    testWidgets('find base value when no punctuality update comes', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, 'T6');

      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      await tester.tap(primaryButton);

      // wait for train journey to load
      await tester.pumpAndSettle();

      //find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      //Find the text in the header
      expect(find.descendant(of: headerFinder, matching: find.text('+00:00')), findsOneWidget);

      await tester.pumpAndSettle();
    });

    testWidgets('check if the displayed current time is correct', (tester) async {
      // Load app widget.
      await prepareAndStartApp(tester);

      //Select the correct train number
      final trainNumberText = findTextFieldByLabel(l10n.p_train_selection_trainnumber_description);
      expect(trainNumberText, findsOneWidget);

      await enterText(tester, trainNumberText, 'T6');

      //Log into the journey
      final primaryButton = find.byWidgetPredicate((widget) => widget is SBBPrimaryButton).first;
      await tester.tap(primaryButton);

      // wait for train journey to load
      await tester.pumpAndSettle();

      //find the header and check if it is existent
      final headerFinder = find.byType(Header);
      expect(headerFinder, findsOneWidget);

      final DateTime currentTime = DateTime.now();
      final String currentHour = currentTime.hour <= 9 ? '0${currentTime.hour}' : (currentTime.hour).toString();
      final String currentMinutes = currentTime.minute <= 9 ? '0${currentTime.minute}' : (currentTime.minute).toString();
      final String currentSeconds = currentTime.second <= 9 ? '0${currentTime.second}' : (currentTime.second).toString();
      final String nextSecond =
      currentTime.second <= 9 ? '0${currentTime.second + 1}' : (currentTime.second + 1).toString();
      final String currentWholeTime = '$currentHour:$currentMinutes:$currentSeconds';
      final String nextSecondWholeTime = '$currentHour:$currentMinutes:$nextSecond';

      if (!find.descendant(of: headerFinder, matching: find.text(currentWholeTime)).evaluate().isNotEmpty) {
        expect(find.descendant(of: headerFinder, matching: find.text(nextSecondWholeTime)), findsOneWidget);
      } else {
        expect(find.descendant(of: headerFinder, matching: find.text(currentWholeTime)), findsOneWidget);
      }

      await tester.pumpAndSettle();
    });

    testWidgets('find low battery icon when battery is beneath 30%', (tester) async {

    });
  });
}

void _checkTrackEquipmentOnServicePoint(String name, Key expectedKey, {bool hasConvExtSpeedBorder = false}) {
  final servicePointRow = findDASTableRowByText(name);
  final trackEquipment = find.descendant(of: servicePointRow, matching: find.byKey(expectedKey));
  expect(trackEquipment, findsOneWidget);

  final convExtSpeedBorder = find.descendant(
      of: servicePointRow, matching: find.byKey(TrackEquipmentCellBody.conventionalExtendedSpeedBorderKey));
  expect(convExtSpeedBorder, hasConvExtSpeedBorder ? findsOneWidget : findsNothing);
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

Future<void> _selectBreakSeries(WidgetTester tester, {required String breakSeries}) async {
  // Open break series bottom sheet
  await tapElement(tester, find.byKey(TrainJourney.breakingSeriesHeaderKey));

  // Check if the bottom sheeet is opened
  expect(find.text(l10n.p_train_journey_break_series), findsOneWidget);
  await tapElement(tester, find.text(breakSeries));

  // confirm button
  await tapElement(tester, find.text(l10n.c_button_confirm));
}
