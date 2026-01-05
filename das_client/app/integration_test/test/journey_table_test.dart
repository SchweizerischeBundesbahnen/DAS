import 'package:app/pages/journey/journey_table/widgets/communication_network_icon.dart';
import 'package:app/pages/journey/journey_table/widgets/journey_table.dart';
import 'package:app/pages/journey/journey_table/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/balise_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cells/bracket_station_cell_body.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/journey_table/widgets/table/curve_point_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/protection_section_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/service_point_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/signal_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/tram_area_row.dart';
import 'package:app/pages/journey/journey_table/widgets/table/whistle_row.dart';
import 'package:app/theme/themes.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:app/widgets/labeled_badge.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey table test', () {
    testWidgets('test journey displays end of curves correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T5');

      //find first curve
      final firstCurve = findDASTableRowByText('${l10n.p_journey_table_curve_type_curve} km 65.30 - 65.80');
      expect(firstCurve, findsOneWidget);

      //find second curve curve
      final secondCurve = findDASTableRowByText('${l10n.p_journey_table_curve_type_curve} km 42.50 - 42.00');
      expect(secondCurve, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test journey displays summarized curve as one', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T5');

      //find pause button and press it
      final pauseButton = find.text(l10n.p_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      final dasTable = find.byType(DASTable);
      expect(dasTable, findsOneWidget);

      final summarizedCurveRow = findDASTableRowByText(
        '${l10n.p_journey_table_curve_type_curve} km 33.80 - 30.50',
      );
      await tester.dragUntilVisible(summarizedCurveRow, dasTable, const Offset(0.0, -5));
      expect(summarizedCurveRow, findsOneWidget);

      final speed = find.descendant(of: summarizedCurveRow, matching: find.byType(SpeedDisplay));
      expect(speed, findsOneWidget);

      //find all speeds and the partition in between separately because they are different widgets
      final summarizedCurvesSpeeds = find.descendant(of: speed, matching: find.text('50-30-91'));
      expect(summarizedCurvesSpeeds, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test displays kilometer and communication network changes correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      // find pause button and press it
      final pauseButton = find.text(l10n.p_journey_header_button_pause);
      expect(pauseButton, findsOneWidget);

      await tapElement(tester, pauseButton);

      final dasTable = find.byType(DASTable);
      expect(dasTable, findsOneWidget);

      // find gsmP-Icon
      final gsmPKey = find.descendant(of: dasTable, matching: find.byKey(CommunicationNetworkIcon.gsmPKey));
      expect(gsmPKey, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test up- and downhill gradient is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T15M');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final renensRow = findDASTableRowByText('Renens VD');
      expect(renensRow, findsAny);

      final renensGradient = find.descendant(of: renensRow.first, matching: find.text('10'));
      expect(renensGradient, findsOneWidget);

      await dragUntilTextInStickyHeader(tester, 'Lausanne');

      final pullyRow = findDASTableRowByText('Pully');
      expect(pullyRow, findsAny);

      final pullyGradient = find.descendant(of: pullyRow, matching: find.text('11'));
      expect(pullyGradient, findsOneWidget);

      await dragUntilTextInStickyHeader(tester, 'Pully');

      final taillepiedRow = findDASTableRowByText('Taillepied');
      expect(taillepiedRow, findsAny);

      final taillepiedGradientUp = find.descendant(of: taillepiedRow, matching: find.text('3'));
      expect(taillepiedGradientUp, findsOneWidget);

      final taillepiedGradientDown = find.descendant(of: taillepiedRow, matching: find.text('8'));
      expect(taillepiedGradientDown, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test find two curves found when breakingSeries A50 is chosen', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T5');

      // change breakseries to A50
      await selectBreakSeries(tester, breakSeries: 'A50');

      // check if the breakseries A50 is chosen.
      final breakingSeriesHeaderCell = find.byKey(JourneyTable.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('A50')), findsOneWidget);

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final curveName = find.textContaining(l10n.p_journey_table_curve_type_curve);
      expect(curveName, findsExactly(2));

      final curveIcon = find.byKey(CurvePointRow.curvePointIconKey);
      expect(curveIcon, findsExactly(2));

      await disconnect(tester);
    });

    testWidgets('test find three curves when breakingSeries R115 is chosen', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T5');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // find and check if the default break series is chosen
      final breakingSeriesHeaderCell = find.byKey(JourneyTable.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('R115')), findsOneWidget);

      final curveName = find.textContaining(l10n.p_journey_table_curve_type_curve);
      expect(curveName, findsExactly(3));

      final curveIcon = find.byKey(CurvePointRow.curvePointIconKey);
      expect(curveIcon, findsExactly(3));

      await disconnect(tester);
    });

    testWidgets('test balise multiple level crossings', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T7');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final baliseMultiLevelCrossing = findDASTableRowByText('(2 ${l10n.p_journey_table_level_crossing})');
      expect(baliseMultiLevelCrossing, findsOneWidget);

      final baliseIcon = find.descendant(of: baliseMultiLevelCrossing, matching: find.byKey(BaliseRow.baliseIconKey));
      expect(baliseIcon, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test whistle and tram area', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T7');

      final whistleRow = findDASTableRowByText('39.6');
      expect(whistleRow, findsOneWidget);

      final whistleIcon = find.descendant(of: whistleRow, matching: find.byKey(WhistleRow.whistleIconKey));
      expect(whistleIcon, findsOneWidget);

      final tramAreaRow = findDASTableRowByText('km 37.8-36.8');
      expect(tramAreaRow, findsAny);

      final tramAreaIcon = find.descendant(of: tramAreaRow, matching: find.byKey(TramAreaRow.tramAreaIconKey));
      expect(tramAreaIcon, findsAny);

      final tramAreaDescription = find.descendant(of: tramAreaRow, matching: find.text('6 TS'));
      expect(tramAreaDescription, findsAny);

      await disconnect(tester);
    });

    testWidgets('test balise and level crossing groups expand / collapse', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T7');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final groupOf5BaliseRow = findDASTableRowByText('41.6');
      expect(groupOf5BaliseRow, findsOneWidget);

      final countText = find.descendant(of: groupOf5BaliseRow, matching: find.text('5'));
      expect(countText, findsOneWidget);

      final levelCrossingText = find.descendant(
        of: groupOf5BaliseRow,
        matching: find.text(l10n.p_journey_table_level_crossing),
      );
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
        find.descendant(of: detailRowLevelCrossing, matching: find.text(l10n.p_journey_table_level_crossing)),
        findsOneWidget,
      );

      // collapse group
      await tapElement(tester, groupOf5BaliseRow);

      detailRowBalise = findDASTableRowByText('41.552');
      detailRowLevelCrossing = findDASTableRowByText('41.492');

      expect(detailRowLevelCrossing, findsNothing);
      expect(detailRowBalise, findsNothing);

      await disconnect(tester);
    });

    testWidgets('test speed values of default breakSeries (R115)', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T5');

      final expectedSpeeds = {
        'Genève-Aéroport': '60',
        '65.3': '44', // 1. Curve
        'New Line Speed All': '60',
        'Genève': '60',
        'New Line Speed A Missing': '60',
        '42.5': '44', // 2. Curve
        '33.8': '50-30-91', // 3. Curve
        'Gland': '60',
      };

      for (final entry in expectedSpeeds.entries) {
        final tableRow = findDASTableRowByText(entry.key);
        expect(tableRow, findsOneWidget);

        final speedText = find.descendant(of: tableRow, matching: find.text(entry.value));
        expect(speedText, findsOneWidget);
      }

      await disconnect(tester);
    });

    testWidgets('test speed values of missing break Series', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T5');
      await selectBreakSeries(tester, breakSeries: 'A85');

      final breakingSeriesHeaderCell = find.byKey(JourneyTable.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('A85')), findsOneWidget);

      final expectedSpeeds = {
        'Genève-Aéroport': '90',
        '65.3': '55',
        'New Line Speed All': '90',
        '33.8': '60-70-53',
        'Gland': '90',
      };

      // Check all expected values (excluding the exception)
      for (final entry in expectedSpeeds.entries) {
        final tableRow = findDASTableRowByText(entry.key);
        expect(tableRow, findsOneWidget);

        final speedText = find.descendant(of: tableRow, matching: find.text(entry.value));
        expect(speedText, findsOneWidget);
      }

      final newLineSpeedRow = findDASTableRowByText('New Line Speed A Missing');
      expect(newLineSpeedRow, findsOneWidget);

      final emptyCellsInNewLineSpeedRow = find.descendant(
        of: newLineSpeedRow,
        matching: find.byKey(DASTableCell.emptyCellKey),
      );
      expect(emptyCellsInNewLineSpeedRow, findsNWidgets(10));

      final genevaRow = findDASTableRowByText('Genève');
      expect(genevaRow, findsOneWidget);

      final emptyCellsInGenevaRow = find.descendant(of: genevaRow, matching: find.byKey(DASTableCell.emptyCellKey));
      expect(emptyCellsInGenevaRow, findsNWidgets(11));

      await disconnect(tester);
    });

    testWidgets('test connection track is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final weicheRow = findDASTableRowByText(l10n.c_connection_track_weiche);
      expect(weicheRow, findsOneWidget);

      final weicheKilometre = find.descendant(of: weicheRow, matching: find.text('0.8'));
      expect(weicheKilometre, findsOneWidget);

      await tester.dragUntilVisible(find.text('AnG. WITZ'), scrollableFinder, const Offset(0, -50));

      final connectionTrackRow = findDASTableRowByText('AnG. WITZ');
      expect(connectionTrackRow, findsOneWidget);

      await tester.dragUntilVisible(find.text('22-6 Uhr'), scrollableFinder, const Offset(0, -50));

      final connectionTrackWithSpeedRow = findDASTableRowByText('22-6 Uhr');
      expect(connectionTrackWithSpeedRow, findsOneWidget);

      await tester.dragUntilVisible(find.text('Zahnstangen Anfang'), scrollableFinder, const Offset(0, -50));

      final zahnstangeAnfangRow = findDASTableRowByText('Zahnstangen Anfang');
      expect(zahnstangeAnfangRow, findsOneWidget);

      await tester.dragUntilVisible(find.text('Zahnstangen Ende'), scrollableFinder, const Offset(0, -50));

      final zahnstangeEndeRow = findDASTableRowByText('Zahnstangen Ende');
      expect(zahnstangeEndeRow, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test additional speed restriction row is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T2');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final asrRow = findDASTableRowByText('km 64.200 - km 47.200');
      expect(asrRow, findsOneWidget);

      final asrIcon = find.descendant(
        of: asrRow,
        matching: find.byKey(AdditionalSpeedRestrictionRow.additionalSpeedRestrictionIconKey),
      );
      expect(asrIcon, findsOneWidget);

      final asrSpeed = find.descendant(of: asrRow, matching: find.text('60'));
      expect(asrSpeed, findsOneWidget);

      // check all cells are colored
      final coloredCells = findColoredRowCells(
        of: asrRow,
        color: AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor,
      );
      expect(coloredCells, findsNWidgets(14));

      await disconnect(tester);
    });

    testWidgets('test complex additional speed restriction row is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T18');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final asrRows = findDASTableRowByText('km 64.200 - km 26.100');
      expect(asrRows, findsAtLeast(1));

      final asrRow = asrRows.first;

      // no count badge should be shown for normal ASR
      final asrCountBadge = find.descendant(
        of: asrRow,
        matching: find.byKey(LabeledBadge.labeledBadgeKey),
      );
      expect(asrCountBadge, findsNothing);

      // scroll to complex ASR
      final rowFinder = find.descendant(of: scrollableFinder, matching: find.text('WANZ'));
      await tester.dragUntilVisible(rowFinder, scrollableFinder, const Offset(0, -100));

      final complexAsr = findDASTableRowByText('km 83.100 - km 6.600');
      expect(complexAsr, findsOneWidget);

      // check count badge
      final complexAsrCountBadge = find.descendant(of: complexAsr, matching: find.byKey(LabeledBadge.labeledBadgeKey));
      expect(complexAsrCountBadge, findsOneWidget);
      final countBadgeText = find.descendant(of: complexAsrCountBadge, matching: find.text('2'));
      expect(countBadgeText, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test other rows are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T2');

      final scrollableFinder = find.byType(AnimatedList);
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
        final coloredCells = findColoredRowCells(
          of: testRow,
          color: AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor,
        );
        expect(coloredCells, findsNWidgets(6));
      }

      await disconnect(tester);
    });

    testWidgets('check if all table columns with header are present', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T6');

      // List of expected column headers
      final List<String> expectedHeaders = [
        l10n.p_journey_table_kilometre_label,
        l10n.p_journey_table_journey_information_label,
        l10n.p_journey_table_time_label_planned,
        l10n.p_journey_table_advised_speed_label,
        l10n.p_journey_table_graduated_speed_label,
      ];

      // Check if each header is present in the widget tree
      for (final header in expectedHeaders) {
        expect(findDASTableColumnByText(header), findsOneWidget);
      }

      await disconnect(tester);
    });

    testWidgets('test route is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final stopRouteRow = findDASTableRowByText('(Bahnhof A)');
      expect(stopRouteRow, findsOneWidget);

      await tester.dragUntilVisible(findDASTableRowByText('Haltestelle B'), scrollableFinder, const Offset(0, -50));

      final nonStoppingPassRouteRow = findDASTableRowByText('Haltestelle B');
      expect(nonStoppingPassRouteRow, findsOneWidget);

      // check stop circles
      final stopRoute = find.descendant(of: stopRouteRow, matching: find.byKey(RouteCellBody.stopKey));
      final nonStoppingPassRoute = find.descendant(
        of: nonStoppingPassRouteRow,
        matching: find.byKey(RouteCellBody.stopKey),
      );
      expect(stopRoute, findsOneWidget);
      expect(nonStoppingPassRoute, findsNothing);

      // check route start
      final routeStart = find.descendant(
        of: find.byKey(DASTable.tableKey),
        matching: find.byKey(RouteCellBody.routeStartKey),
      );
      expect(routeStart, findsAny);

      await tester.dragUntilVisible(find.byKey(RouteCellBody.routeEndKey), scrollableFinder, const Offset(0, -50));

      // check route end
      final routeEnd = find.byKey(RouteCellBody.routeEndKey);
      expect(routeEnd, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test protection sections are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T3');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // check first train station
      expect(findDASTableRowByText('Genève-Aéroport'), findsOneWidget);

      // Scroll to first protection section
      await tester.dragUntilVisible(find.text('Gilly-Bursinel'), scrollableFinder, const Offset(0, -20));

      var protectionSectionRow = findDASTableRowByText('km 32.2');
      expect(protectionSectionRow, findsOneWidget);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('FL')), findsOneWidget);
      expect(find.descendant(of: protectionSectionRow, matching: find.text('32.2')), findsOneWidget);
      // Verify icon is displayed
      expect(
        find.descendant(of: protectionSectionRow, matching: find.byKey(ProtectionSectionRow.protectionSectionKey)),
        findsOneWidget,
      );

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

      await disconnect(tester);
    });

    testWidgets('test both kilometres are displayed', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T6');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final hardbruckeRow = findDASTableRowByText('Hardbrücke');
      expect(hardbruckeRow, findsOneWidget);
      expect(find.descendant(of: hardbruckeRow, matching: find.text('1.9')), findsOneWidget);
      expect(find.descendant(of: hardbruckeRow, matching: find.text('23.5')), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test bracket stations is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('Klammerbahnhof D1'), scrollableFinder, const Offset(0, -50));

      final bracketStationD = findDASTableRowByText('Klammerbahnhof D');
      final zahnstangenEnde = findDASTableRowByText('Zahnstangen Ende');
      final deckungssignal = findDASTableRowByText(l10n.c_main_signal_function_protection);
      final bracketStationD1 = findDASTableRowByText('Klammerbahnhof D1');
      expect(bracketStationD, findsOneWidget);
      expect(zahnstangenEnde, findsOneWidget);
      expect(deckungssignal, findsOneWidget);
      expect(bracketStationD1, findsOneWidget);

      // check if the bracket station widget is displayed
      final bracketStationDWidget = find.descendant(
        of: bracketStationD,
        matching: find.byKey(BracketStationCellBody.bracketStationKey),
      );
      final zahnstangenEndeWidget = find.descendant(
        of: zahnstangenEnde,
        matching: find.byKey(BracketStationCellBody.bracketStationKey),
      );
      final deckungssignalWidget = find.descendant(
        of: deckungssignal,
        matching: find.byKey(BracketStationCellBody.bracketStationKey),
      );
      final bracketStationD1Widget = find.descendant(
        of: bracketStationD1,
        matching: find.byKey(BracketStationCellBody.bracketStationKey),
      );
      expect(bracketStationDWidget, findsOneWidget);
      expect(zahnstangenEndeWidget, findsOneWidget);
      expect(deckungssignalWidget, findsOneWidget);
      expect(bracketStationD1Widget, findsOneWidget);

      // check that the abbreviation is displayed correctly
      expect(find.descendant(of: bracketStationDWidget, matching: find.text('D')), findsOneWidget);
      expect(find.descendant(of: zahnstangenEndeWidget, matching: find.text('D')), findsNothing);
      expect(find.descendant(of: deckungssignalWidget, matching: find.text('D')), findsNothing);
      expect(find.descendant(of: bracketStationD1Widget, matching: find.text('D')), findsNothing);

      await disconnect(tester);
    });

    testWidgets('test halt on request is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      await tester.dragUntilVisible(find.text('Klammerbahnhof D'), scrollableFinder, const Offset(0, -50));

      final stopOnDemandRow = findDASTableRowByText('Halt auf Verlangen C');
      expect(stopOnDemandRow, findsOneWidget);

      final stopOnRequestIcon = find.descendant(
        of: stopOnDemandRow,
        matching: find.byKey(ServicePointRow.stopOnRequestKey),
      );
      expect(stopOnRequestIcon, findsOneWidget);

      final stopOnRequestRoute = find.descendant(
        of: stopOnDemandRow,
        matching: find.byKey(RouteCellBody.stopOnRequestKey),
      );
      final stopRoute = find.descendant(of: stopOnDemandRow, matching: find.byKey(RouteCellBody.stopKey));
      expect(stopOnRequestRoute, findsOneWidget);
      expect(stopRoute, findsNothing);

      await disconnect(tester);
    });

    testWidgets('test halt is displayed italic', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T6');

      final glanzenbergRow = findDASTableRowByText('Glanzenberg');
      final glanzenbergTextStyle = find.descendant(
        of: glanzenbergRow,
        matching: find.byWidgetPredicate(
          (it) => it is DefaultTextStyle && it.style.fontStyle == FontStyle.italic,
        ),
      );
      expect(glanzenbergTextStyle, findsOneWidget);

      final schlierenRow = findDASTableRowByText('Schlieren');
      final schlierenTextStyle = find.descendant(
        of: schlierenRow,
        matching: find.byWidgetPredicate(
          (it) => it is DefaultTextStyle && it.style.fontStyle == FontStyle.italic,
        ),
      );
      expect(schlierenTextStyle, findsNothing);

      await disconnect(tester);
    });

    testWidgets('whenServicePointHasTrackGroup_isDisplayedCorrectlyDependingOnDetailModal', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T6M');

      final hardbrueckeRow = findDASTableRowByText('Hardbrücke');
      final trackGroupWidget = find.descendant(of: hardbrueckeRow, matching: find.text('3'));
      expect(trackGroupWidget, findsOneWidget);

      // open modal sheet and test track group still displayed
      await tapElement(tester, hardbrueckeRow);
      await tester.pumpAndSettle();
      expect(trackGroupWidget, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test curves are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      await loadJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final curveLabel = l10n.p_journey_table_curve_type_curve;
      await tester.dragUntilVisible(find.text(curveLabel).first, scrollableFinder, const Offset(0, -50));

      final curveRows = findDASTableRowByText(curveLabel);
      expect(curveRows, findsAtLeast(1));

      final curveIcon = find.descendant(of: curveRows.first, matching: find.byKey(CurvePointRow.curvePointIconKey));
      expect(curveIcon, findsOneWidget);

      final curveAfterHaltLabel = l10n.p_journey_table_curve_type_curve_after_halt;
      await tester.dragUntilVisible(find.text(curveAfterHaltLabel), scrollableFinder, const Offset(0, -50));

      final curveAfterHaltRow = findDASTableRowByText(curveAfterHaltLabel);
      expect(curveAfterHaltRow, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test signals are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // check if signals with both functions laneChange, block are correct
      await tester.dragUntilVisible(find.text('S1'), scrollableFinder, const Offset(0, -50));
      final laneChangeBlockSignalRow = findDASTableRowByText('S1');
      expect(laneChangeBlockSignalRow, findsOneWidget);
      expect(
        find.descendant(of: laneChangeBlockSignalRow, matching: find.text(l10n.c_main_signal_function_block)),
        findsOneWidget,
      );
      final laneChangeIcon = find.descendant(
        of: laneChangeBlockSignalRow,
        matching: find.byKey(SignalRow.signalLineChangeIconKey),
      );
      expect(laneChangeIcon, findsOneWidget);

      // check if basic signal is rendered correctly
      await tester.dragUntilVisible(
        find.text(l10n.c_main_signal_function_protection),
        scrollableFinder,
        const Offset(0, -50),
      );
      final protectionSignalRow = findDASTableRowByText(l10n.c_main_signal_function_protection);
      expect(protectionSignalRow, findsOneWidget);
      expect(find.descendant(of: protectionSignalRow, matching: find.text('D1')), findsOneWidget);
      final noLaneChangeIcon = find.descendant(
        of: protectionSignalRow,
        matching: find.byKey(SignalRow.signalLineChangeIconKey),
      );
      expect(noLaneChangeIcon, findsNothing);

      // check if signals with multiple functions are rendered correctly
      final signalLabel = '${l10n.c_main_signal_function_block}/${l10n.c_main_signal_function_intermediate}';
      await tester.dragUntilVisible(find.text(signalLabel), scrollableFinder, const Offset(0, -50));
      final blockIntermediateSignalRow = findDASTableRowByText(signalLabel);
      expect(blockIntermediateSignalRow, findsOneWidget);
      expect(find.descendant(of: blockIntermediateSignalRow, matching: find.text('BAB1')), findsOneWidget);
      final noLaneChangeIcon2 = find.descendant(
        of: blockIntermediateSignalRow,
        matching: find.byKey(SignalRow.signalLineChangeIconKey),
      );
      expect(noLaneChangeIcon2, findsNothing);

      await disconnect(tester);
    });

    testWidgets('test if station speeds are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T8');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // check station speeds for Bern

      final bernStationRow = findDASTableRowByText('Bern');
      expect(bernStationRow, findsOneWidget);
      final bernIncomingSpeeds = find.descendant(
        of: bernStationRow,
        matching: find.byKey(SpeedDisplay.incomingSpeedsKey),
      );
      expect(bernIncomingSpeeds, findsNWidgets(2));
      final bernIncomingSpeedsText = find.descendant(of: bernStationRow, matching: find.text('75-70-60'));
      expect(bernIncomingSpeedsText, findsOneWidget);
      final bernOutgoingSpeeds = find.descendant(
        of: bernStationRow,
        matching: find.byKey(SpeedDisplay.outgoingSpeedsKey),
      );
      expect(bernOutgoingSpeeds, findsNothing);

      // check station speeds for Wankdorf, no station speeds given

      final wankdorfStationRow = findDASTableRowByText('Wankdorf');
      expect(wankdorfStationRow, findsOneWidget);
      final wankdorfIncomingSpeeds = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedDisplay.incomingSpeedsKey),
      );
      expect(wankdorfIncomingSpeeds, findsNothing);
      final wankdorfOutgoingSpeeds = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedDisplay.outgoingSpeedsKey),
      );
      expect(wankdorfOutgoingSpeeds, findsNothing);

      // check station speeds for Burgdorf

      final burgdorfStationRow = findDASTableRowByText('Burgdorf');
      expect(burgdorfStationRow, findsOneWidget);
      final burgdorfIncomingSpeeds = find.descendant(
        of: burgdorfStationRow,
        matching: find.byKey(SpeedDisplay.incomingSpeedsKey),
      );
      expect(burgdorfIncomingSpeeds, findsNWidgets(2));
      final burgdorfIncomingSpeeds75 = find.descendant(of: burgdorfIncomingSpeeds, matching: find.text('75'));
      expect(burgdorfIncomingSpeeds75, findsOneWidget);
      final burgdorfIncomingSpeeds70 = find.descendant(of: burgdorfIncomingSpeeds, matching: find.text('70'));
      expect(burgdorfIncomingSpeeds70, findsOneWidget);
      final burgdorfIncomingSpeeds70Circled = find.ancestor(
        of: burgdorfIncomingSpeeds70,
        matching: find.byKey(SpeedDisplay.circledSpeedKey),
      );
      expect(burgdorfIncomingSpeeds70Circled, findsOneWidget);
      final burgdorfOutgoingSpeeds = find.descendant(
        of: burgdorfStationRow,
        matching: find.byKey(SpeedDisplay.outgoingSpeedsKey),
      );
      expect(burgdorfOutgoingSpeeds, findsOneWidget);
      final burgdorfOutgoingSpeeds60 = find.descendant(of: burgdorfOutgoingSpeeds, matching: find.text('60'));
      expect(burgdorfOutgoingSpeeds60, findsOneWidget);
      final burgdorfOutgoingSpeeds60Squared = find.ancestor(
        of: burgdorfOutgoingSpeeds60,
        matching: find.byKey(SpeedDisplay.squaredSpeedKey),
      );
      expect(burgdorfOutgoingSpeeds60Squared, findsOneWidget);

      // check station speeds for Olten, no graduated speed for train series R

      final oltenStationRow = findDASTableRowByText('Olten');
      expect(oltenStationRow, findsOneWidget);
      final oltenIncomingSpeeds = find.descendant(
        of: oltenStationRow,
        matching: find.byKey(SpeedDisplay.incomingSpeedsKey),
      );
      expect(oltenIncomingSpeeds, findsOneWidget);
      final oltenOutgoingSpeeds = find.descendant(
        of: oltenStationRow,
        matching: find.byKey(SpeedDisplay.outgoingSpeedsKey),
      );
      expect(oltenOutgoingSpeeds, findsNothing);

      // check correct display for Aarau (only blue indicator - no local speed)
      await dragUntilTextInStickyHeader(tester, 'Dulliken');
      final aarauStationRow = findDASTableRowByText('Aarau');
      expect(aarauStationRow, findsOneWidget);
      final aarauIncomingSpeeds = find.descendant(
        of: aarauStationRow,
        matching: find.byKey(SpeedDisplay.incomingSpeedsKey),
      );
      expect(aarauIncomingSpeeds, findsNothing);
      final aarauOutgoingSpeeds = find.descendant(
        of: aarauStationRow,
        matching: find.byKey(SpeedDisplay.outgoingSpeedsKey),
      );
      expect(aarauOutgoingSpeeds, findsNothing);

      final aarauDotIndicator = find.descendant(
        of: aarauStationRow,
        matching: find.byKey(DotIndicator.indicatorKey),
      );
      expect(aarauDotIndicator, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test line speed always displayed in sticky header', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T8');

      // now empty
      final wankdorfStationRow = findDASTableRowByText('Wankdorf');
      expect(wankdorfStationRow, findsOneWidget);
      final wankdorfIncomingSpeedsEmpty = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedDisplay.incomingSpeedsKey),
      );
      expect(wankdorfIncomingSpeedsEmpty, findsNothing);
      final wankdorfOutgoingSpeedsEmpty = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedDisplay.outgoingSpeedsKey),
      );
      expect(wankdorfOutgoingSpeedsEmpty, findsNothing);

      await dragUntilTextInStickyHeader(tester, 'Wankdorf');

      await tester.pumpAndSettle();

      // now filled
      final wankdorfIncomingSpeedsFilled = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedDisplay.incomingSpeedsKey),
      );
      expect(wankdorfIncomingSpeedsFilled, findsNWidgets(1));
      final bernIncomingSpeedsText = find.descendant(of: wankdorfStationRow, matching: find.text('90'));
      expect(bernIncomingSpeedsText, findsOneWidget);
      final wankdorfIncomingSpeedsEmpty2 = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedDisplay.outgoingSpeedsKey),
      );
      expect(wankdorfIncomingSpeedsEmpty2, findsNothing);
    });

    testWidgets('test additional speed restriction row are displayed correctly on ETCS level 2 section', (
      tester,
    ) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T11');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // ASR from 40km/h should be displayed if not completely inside ETCS L2
      final asrRow1 = findDASTableRowByText('km 9.000 - km 26.000');
      expect(asrRow1, findsExactly(2));

      final asrSpeed1 = find.descendant(of: asrRow1.first, matching: find.text('50'));
      expect(asrSpeed1, findsOneWidget);

      await tester.dragUntilVisible(find.text('Neuchâtel'), scrollableFinder, const Offset(0, -50));

      final asrRow2 = findDASTableRowByText('km 29.000 - km 39.000');
      expect(asrRow2, findsExactly(2));

      final asrSpeed2 = find.descendant(of: asrRow2.first, matching: find.text('30'));
      expect(asrSpeed2, findsOneWidget);

      await tester.dragUntilVisible(find.text('Lengnau'), scrollableFinder, const Offset(0, -50));

      // ASR from 40km/h should not be displayed inside ETCS L2
      final asrRow3 = findDASTableRowByText('km 41.000 - km 46.000');
      expect(asrRow3, findsNothing);

      await tester.dragUntilVisible(find.text('Solothurn'), scrollableFinder, const Offset(0, -50));

      // ASR from 40km/h should be displayed if not completely inside ETCS L2
      final asrRow4 = findDASTableRowByText('km 51.000 - km 59.000');
      expect(asrRow4, findsExactly(2));

      final asrSpeed4 = find.descendant(of: asrRow4.first, matching: find.text('40'));
      expect(asrSpeed4, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test line speed is hidden on ETCS level 2 section', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T11');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final speedChangeText = 'Speed Hidden ETCSL2';
      await tester.dragUntilVisible(find.text(speedChangeText), scrollableFinder, const Offset(0, -50));
      final speedChangeRow = findDASTableRowByText(speedChangeText);
      expect(speedChangeRow, findsOneWidget);

      final speedChangeRowSpeed = find.descendant(of: speedChangeRow, matching: find.text('50'));
      expect(speedChangeRowSpeed, findsNothing);

      await disconnect(tester);
    });

    testWidgets('test additional service points displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T27');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // check if all additional service points are displayed correctly
      await _checkAdditionalServicePoint(tester, scrollableFinder, 'Bern (Depot)');
      await _checkAdditionalServicePoint(tester, scrollableFinder, 'Olten Ost (Abzw)');
      await _checkAdditionalServicePoint(tester, scrollableFinder, 'Olten Tunnel (Spw)');
      await _checkAdditionalServicePoint(tester, scrollableFinder, 'Dulliken (Depot)');

      await disconnect(tester);
    });

    testWidgets('test shunting movement markers are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);
      await loadJourney(tester, trainNumber: 'T29');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // start marking of first shunting movement segment
      final firstStartMarking = findDASTableRowByText(l10n.w_shunting_movement_start('T29R'));
      expect(firstStartMarking, findsAny);

      // end marking of first shunting movement segment
      final firstEndMarking = findDASTableRowByText(l10n.w_shunting_movement_end('T29'));
      await tester.dragUntilVisible(firstEndMarking, scrollableFinder, const Offset(0, -50));
      expect(firstEndMarking, findsOneWidget);

      await dragUntilTextInStickyHeader(tester, 'Zürich Altstetten');

      // start marking of second shunting movement segment
      final secondStartMarking = findDASTableRowByText(l10n.w_shunting_movement_start('T29R'));
      expect(secondStartMarking, findsOneWidget);

      // finds no end marking as it is outside of journey
      final secondEndMarking = findDASTableRowByText(l10n.w_shunting_movement_end('T29'));
      expect(secondEndMarking, findsNothing);

      await disconnect(tester);
    });
  });
}

Future<void> _checkAdditionalServicePoint(WidgetTester tester, Finder scrollableFinder, String servicePointName) async {
  final servicePointRow = findDASTableRowByText(servicePointName);
  await tester.dragUntilVisible(servicePointRow, scrollableFinder, const Offset(0, -50));
  expect(servicePointRow, findsOneWidget);

  // check all cells are colored
  final coloredCells = findColoredRowCells(
    of: servicePointRow,
    color: DASTheme.light().scaffoldBackgroundColor,
  );
  expect(coloredCells, findsAtLeast(3));
}
