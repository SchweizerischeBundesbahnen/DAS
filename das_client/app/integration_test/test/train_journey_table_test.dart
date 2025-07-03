import 'package:app/pages/journey/train_journey/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/balise_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/bracket_station_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/speed_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/time_cell_body.dart';
import 'package:app/pages/journey/train_journey/widgets/table/curve_point_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/protection_section_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/signal_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/tram_area_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/whistle_row.dart';
import 'package:app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:app/util/format.dart';
import 'package:app/widgets/labeled_badge.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  group('train journey table test', () {
    testWidgets('test up- and downhill gradient is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T15');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final renensRow = findDASTableRowByText('Renens VD');
      expect(renensRow, findsAny);

      final renensGradient = find.descendant(of: renensRow.first, matching: find.text('10'));
      expect(renensGradient, findsOneWidget);

      await tester.dragUntilVisible(find.text('Pully'), scrollableFinder, const Offset(0, -50));

      final pullyRow = findDASTableRowByText('Pully');
      expect(pullyRow, findsAny);

      final pullyGradient = find.descendant(of: pullyRow, matching: find.text('11'));
      expect(pullyGradient, findsOneWidget);

      await tester.dragUntilVisible(find.text('Taillepied'), scrollableFinder, const Offset(0, -50));

      final taillepiedRow = findDASTableRowByText('Taillepied');
      expect(taillepiedRow, findsAny);

      final taillepiedGradientUp = find.descendant(of: taillepiedRow, matching: find.text('3'));
      expect(taillepiedGradientUp, findsOneWidget);

      final taillepiedGradientDown = find.descendant(of: taillepiedRow, matching: find.text('8'));
      expect(taillepiedGradientDown, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test find one curve is found when breakingSeries A50 is chosen', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T5');

      // change breakseries to A50
      await selectBreakSeries(tester, breakSeries: 'A50');

      // check if the breakseries A50 is chosen.
      final breakingSeriesHeaderCell = find.byKey(TrainJourney.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('A50')), findsOneWidget);

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final curveName = findDASTableRowByText(l10n.p_train_journey_table_curve_type_curve);
      expect(curveName, findsOneWidget);

      final curveIcon = find.descendant(of: curveName, matching: find.byKey(CurvePointRow.curvePointIconKey));
      expect(curveIcon, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test find two curves when breakingSeries R115 is chosen', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T5');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // find and check if the default break series is chosen
      final breakingSeriesHeaderCell = find.byKey(TrainJourney.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('R115')), findsOneWidget);

      final curveName = findDASTableRowByText(l10n.p_train_journey_table_curve_type_curve);
      expect(curveName, findsExactly(2));

      final curveIcon = find.descendant(of: curveName, matching: find.byKey(CurvePointRow.curvePointIconKey));
      expect(curveIcon, findsExactly(2));

      await disconnect(tester);
    });

    testWidgets('test balise multiple level crossings', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T7');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final baliseMultiLevelCrossing = findDASTableRowByText('(2 ${l10n.p_train_journey_table_level_crossing})');
      expect(baliseMultiLevelCrossing, findsOneWidget);

      final baliseIcon = find.descendant(of: baliseMultiLevelCrossing, matching: find.byKey(BaliseRow.baliseIconKey));
      expect(baliseIcon, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test whistle and tram area', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T7');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T7');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final groupOf5BaliseRow = findDASTableRowByText('41.6');
      expect(groupOf5BaliseRow, findsOneWidget);

      final countText = find.descendant(of: groupOf5BaliseRow, matching: find.text('5'));
      expect(countText, findsOneWidget);

      final levelCrossingText = find.descendant(
        of: groupOf5BaliseRow,
        matching: find.text(l10n.p_train_journey_table_level_crossing),
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
        find.descendant(of: detailRowLevelCrossing, matching: find.text(l10n.p_train_journey_table_level_crossing)),
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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T5');

      final expectedSpeeds = {
        'Genève-Aéroport': '60',
        '65.3': '44', // 1. Curve
        'New Line Speed All': '60',
        'Genève': '60',
        'New Line Speed A Missing': '60',
        '42.5': '44', // 2. Curve
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

      await loadTrainJourney(tester, trainNumber: 'T5');
      await selectBreakSeries(tester, breakSeries: 'A85');

      final breakingSeriesHeaderCell = find.byKey(TrainJourney.breakingSeriesHeaderKey);
      expect(breakingSeriesHeaderCell, findsOneWidget);
      expect(find.descendant(of: breakingSeriesHeaderCell, matching: find.text('A85')), findsOneWidget);

      final expectedSpeeds = {
        'Genève-Aéroport': '90',
        '65.3': '55',
        'New Line Speed All': '90',
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
      expect(emptyCellsInNewLineSpeedRow, findsNWidgets(11));

      final genevaRow = findDASTableRowByText('Genève');
      expect(genevaRow, findsOneWidget);

      final emptyCellsInGenevaRow = find.descendant(of: genevaRow, matching: find.byKey(DASTableCell.emptyCellKey));
      expect(emptyCellsInGenevaRow, findsNWidgets(12));

      await disconnect(tester);
    });

    testWidgets('test connection track is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T2');

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
      final coloredCells = find.descendant(
        of: asrRow,
        matching: find.byWidgetPredicate(
          (it) =>
              it is Container &&
              it.decoration is BoxDecoration &&
              (it.decoration as BoxDecoration).color == AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor,
        ),
      );
      expect(coloredCells, findsNWidgets(15));

      await disconnect(tester);
    });

    testWidgets('test complex additional speed restriction row is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T18');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T2');

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
        final coloredCells = find.descendant(
          of: testRow,
          matching: find.byWidgetPredicate(
            (it) =>
                it is Container &&
                it.decoration is BoxDecoration &&
                (it.decoration as BoxDecoration).color == AdditionalSpeedRestrictionRow.additionalSpeedRestrictionColor,
          ),
        );
        expect(coloredCells, findsNWidgets(6));
      }

      await disconnect(tester);
    });

    testWidgets('check if all table columns with header are present', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T6');

      // List of expected column headers
      final List<String> expectedHeaders = [
        l10n.p_train_journey_table_kilometre_label,
        l10n.p_train_journey_table_journey_information_label,
        l10n.p_train_journey_table_time_label_planned,
        l10n.p_train_journey_table_advised_speed_label,
        l10n.p_train_journey_table_graduated_speed_label,
      ];

      // Check if each header is present in the widget tree
      for (final header in expectedHeaders) {
        expect(find.text(header), findsOneWidget);
      }

      await disconnect(tester);
    });

    testWidgets('test route is displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final stopRouteRow = findDASTableRowByText('Bahnhof A');
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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T3');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T6');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T6');

      final glanzenbergText = find.byWidgetPredicate(
        (it) => it is Text && it.data == 'Glanzenberg' && it.style?.fontStyle == FontStyle.italic,
      );
      expect(glanzenbergText, findsOneWidget);

      final schlierenText = find.byWidgetPredicate(
        (it) => it is Text && it.data == 'Schlieren' && it.style?.fontStyle != FontStyle.italic,
      );
      expect(schlierenText, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test curves are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

      await selectBreakSeries(tester, breakSeries: 'R150');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      final curveLabel = l10n.p_train_journey_table_curve_type_curve;
      await tester.dragUntilVisible(find.text(curveLabel).first, scrollableFinder, const Offset(0, -50));

      final curveRows = findDASTableRowByText(curveLabel);
      expect(curveRows, findsAtLeast(1));

      final curveIcon = find.descendant(of: curveRows.first, matching: find.byKey(CurvePointRow.curvePointIconKey));
      expect(curveIcon, findsOneWidget);

      final curveAfterHaltLabel = l10n.p_train_journey_table_curve_type_curve_after_halt;
      await tester.dragUntilVisible(find.text(curveAfterHaltLabel), scrollableFinder, const Offset(0, -50));

      final curveAfterHaltRow = findDASTableRowByText(curveAfterHaltLabel);
      expect(curveAfterHaltRow, findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test signals are displayed correctly', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T9999');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T8');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // check station speeds for Bern

      final bernStationRow = findDASTableRowByText('Bern');
      expect(bernStationRow, findsOneWidget);
      final bernIncomingSpeeds = find.descendant(
        of: bernStationRow,
        matching: find.byKey(SpeedCellBody.incomingSpeedsKey),
      );
      expect(bernIncomingSpeeds, findsNWidgets(2));
      final bernIncomingSpeedsText = find.descendant(of: bernStationRow, matching: find.text('75-70-60'));
      expect(bernIncomingSpeedsText, findsOneWidget);
      final bernOutgoingSpeeds = find.descendant(
        of: bernStationRow,
        matching: find.byKey(SpeedCellBody.outgoingSpeedsKey),
      );
      expect(bernOutgoingSpeeds, findsNothing);

      // check station speeds for Wankdorf, no station speeds given

      final wankdorfStationRow = findDASTableRowByText('Wankdorf');
      expect(wankdorfStationRow, findsOneWidget);
      final wankdorfIncomingSpeeds = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedCellBody.incomingSpeedsKey),
      );
      expect(wankdorfIncomingSpeeds, findsNothing);
      final wankdorfOutgoingSpeeds = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedCellBody.outgoingSpeedsKey),
      );
      expect(wankdorfOutgoingSpeeds, findsNothing);

      // check station speeds for Burgdorf

      final burgdorfStationRow = findDASTableRowByText('Burgdorf');
      expect(burgdorfStationRow, findsOneWidget);
      final burgdorfIncomingSpeeds = find.descendant(
        of: burgdorfStationRow,
        matching: find.byKey(SpeedCellBody.incomingSpeedsKey),
      );
      expect(burgdorfIncomingSpeeds, findsNWidgets(2));
      final burgdorfIncomingSpeeds75 = find.descendant(of: burgdorfIncomingSpeeds, matching: find.text('75'));
      expect(burgdorfIncomingSpeeds75, findsOneWidget);
      final burgdorfIncomingSpeeds70 = find.descendant(of: burgdorfIncomingSpeeds, matching: find.text('70'));
      expect(burgdorfIncomingSpeeds70, findsOneWidget);
      final burgdorfIncomingSpeeds70Circled = find.ancestor(
        of: burgdorfIncomingSpeeds70,
        matching: find.byKey(SpeedCellBody.circledSpeedKey),
      );
      expect(burgdorfIncomingSpeeds70Circled, findsOneWidget);
      final burgdorfOutgoingSpeeds = find.descendant(
        of: burgdorfStationRow,
        matching: find.byKey(SpeedCellBody.outgoingSpeedsKey),
      );
      expect(burgdorfOutgoingSpeeds, findsOneWidget);
      final burgdorfOutgoingSpeeds60 = find.descendant(of: burgdorfOutgoingSpeeds, matching: find.text('60'));
      expect(burgdorfOutgoingSpeeds60, findsOneWidget);
      final burgdorfOutgoingSpeeds60Squared = find.ancestor(
        of: burgdorfOutgoingSpeeds60,
        matching: find.byKey(SpeedCellBody.squaredSpeedKey),
      );
      expect(burgdorfOutgoingSpeeds60Squared, findsOneWidget);

      // check station speeds for Olten, no graduated speed for train series R

      final oltenStationRow = findDASTableRowByText('Olten');
      expect(oltenStationRow, findsOneWidget);
      final oltenIncomingSpeeds = find.descendant(
        of: oltenStationRow,
        matching: find.byKey(SpeedCellBody.incomingSpeedsKey),
      );
      expect(oltenIncomingSpeeds, findsOneWidget);
      final oltenOutgoingSpeeds = find.descendant(
        of: oltenStationRow,
        matching: find.byKey(SpeedCellBody.outgoingSpeedsKey),
      );
      expect(oltenOutgoingSpeeds, findsNothing);

      await disconnect(tester);
    });

    testWidgets('test line speed always displayed in sticky header', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T8');

      final scrollableFinder = find.byType(AnimatedList);
      expect(scrollableFinder, findsOneWidget);

      // now empty
      final wankdorfStationRow = findDASTableRowByText('Wankdorf');
      expect(wankdorfStationRow, findsOneWidget);
      final wankdorfIncomingSpeedsEmpty = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedCellBody.incomingSpeedsKey),
      );
      expect(wankdorfIncomingSpeedsEmpty, findsNothing);
      final wankdorfOutgoingSpeedsEmpty = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedCellBody.outgoingSpeedsKey),
      );
      expect(wankdorfOutgoingSpeedsEmpty, findsNothing);

      final stickyHeader = find.byKey(StickyHeader.headerKey);
      await tester.dragUntilVisible(
        find.descendant(of: stickyHeader, matching: find.text('Wankdorf')),
        scrollableFinder,
        const Offset(0, -100),
      );

      await tester.pumpAndSettle();

      // now filled
      final wankdorfIncomingSpeedsFilled = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedCellBody.incomingSpeedsKey),
      );
      expect(wankdorfIncomingSpeedsFilled, findsNWidgets(1));
      final bernIncomingSpeedsText = find.descendant(of: wankdorfStationRow, matching: find.text('90'));
      expect(bernIncomingSpeedsText, findsOneWidget);
      final wankdorfIncomingSpeedsEmpty2 = find.descendant(
        of: wankdorfStationRow,
        matching: find.byKey(SpeedCellBody.outgoingSpeedsKey),
      );
      expect(wankdorfIncomingSpeedsEmpty2, findsNothing);
    });

    testWidgets('test additional speed restriction row are displayed correctly on ETCS level 2 section', (
      tester,
    ) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T11');

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

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T11');

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

    testWidgets('test time cells for journey in far future (T4) with planned times only', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T4');

      // test if planned time header label is in table (no operational times)
      final expectedPlannedHeaderLabel = l10n.p_train_journey_table_time_label_planned;
      final timeHeader = find.text(expectedPlannedHeaderLabel);
      expect(timeHeader, findsOneWidget);

      // two service points have empty times
      final timeCellKey = TimeCellBody.timeCellKey;
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: 'Solothurn'), findsNothing);

      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: 'Solothurn West'), findsNothing);

      // Langendorf should have only departure
      final langendorf = 'Langendorf';
      final expectedTimeLangendorf = Format.plannedTime(DateTime.parse('2025-05-12T16:36:45Z'));

      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: langendorf), findsOneWidget);
      expect(_findTextInDASTableRowByText(innerText: expectedTimeLangendorf, rowText: langendorf), findsOneWidget);

      // Lommiswil has departure and arrival
      final lommiswil = 'Lommiswil';
      final expectedTimeLommiswil =
          '${Format.plannedTime(DateTime.parse('2025-05-12T16:39:12Z'))}\n'
          '${Format.plannedTime(DateTime.parse('2025-05-12T16:40:12Z'))}';
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: lommiswil), findsOneWidget);
      expect(_findTextInDASTableRowByText(innerText: expectedTimeLommiswil, rowText: lommiswil), findsOneWidget);

      // Im Holz (non mandatory stop) has departure
      final holz = 'Im Holz';
      final expectedTimeHolz = Format.plannedTime(DateTime.parse('2025-05-12T16:46:12Z'));
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: holz), findsOneWidget);
      expect(_findTextInDASTableRowByText(innerText: expectedTimeHolz, rowText: holz), findsOneWidget);

      // Oberdorf has only arrival
      final oberdorf = 'Oberdorf SO';
      final expectedTimeOberdorf = '${Format.plannedTime(DateTime.parse('2025-05-12T16:48:45Z'))}\n';
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: oberdorf), findsOneWidget);
      expect(_findTextInDASTableRowByText(innerText: expectedTimeOberdorf, rowText: oberdorf), findsOneWidget);

      // tap header label to switch to planned times
      await tapElement(tester, timeHeader);

      // test if planned time header label is still in table (does not switch)
      expect(find.text(expectedPlannedHeaderLabel), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets('test time cells for journey in near future (T16) with operational and planned times', (tester) async {
      await prepareAndStartApp(tester);

      // load train journey by filling out train selection page
      await loadTrainJourney(tester, trainNumber: 'T16');

      // test if operational time header label is in table
      final expectedCalculatedHeaderLabel = l10n.p_train_journey_table_time_label_new;
      final timeHeader = find.text(expectedCalculatedHeaderLabel);
      expect(timeHeader, findsOneWidget);

      // test if times are displayed correctly
      final timeCellKey = TimeCellBody.timeCellKey;
      // Geneve Aeroport should have only departure operational time
      final geneveAer = 'Genève-Aéroport';
      final expectedTimeGeneveAer = Format.operationalTime(DateTime.parse('2025-05-12T16:14:25Z'));
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: geneveAer), findsOneWidget);
      expect(_findTextInDASTableRowByText(innerText: expectedTimeGeneveAer, rowText: geneveAer), findsOneWidget);
      // morges should have empty times since it does not have operational times
      final morges = 'Morges';
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: morges), findsNothing);
      // vevey should have single operational arrival in brackets since it's a passing point
      final vevey = 'Vevey';
      final expectedTimeVevey = '(${Format.operationalTime(DateTime.parse('2025-05-12T17:28:56Z'))})\n';
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: vevey), findsOneWidget);
      expect(_findTextInDASTableRowByText(innerText: expectedTimeVevey, rowText: vevey), findsOneWidget);

      // tap header label to switch to planned times
      await tapElement(tester, timeHeader);

      // test if planned time header label is in table
      final expectedPlannedHeaderLabel = l10n.p_train_journey_table_time_label_planned;
      expect(find.text(expectedPlannedHeaderLabel), findsOneWidget);
      // test if time switched (aeroport)
      final geneveAerPlanned = 'Genève-Aéroport';
      final expectedTimeGenAerPlanned = Format.plannedTime(DateTime.parse('2025-05-12T15:13:40Z'));
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: geneveAerPlanned), findsOneWidget);
      expect(
        _findTextInDASTableRowByText(innerText: expectedTimeGenAerPlanned, rowText: geneveAerPlanned),
        findsOneWidget,
      );
      // morges
      final morgesPlanned = 'Morges';
      final expectedTimeMorgesPlanned = '(${Format.plannedTime(DateTime.parse('2025-05-12T15:55:23Z'))})\n';
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: morgesPlanned), findsOneWidget);
      expect(
        _findTextInDASTableRowByText(innerText: expectedTimeMorgesPlanned, rowText: morgesPlanned),
        findsOneWidget,
      );
      // vevey should have both times in brackets since it's a passing point
      final veveyPlanned = 'Vevey';
      final expectedTimeVeveyPlanned =
          '(${Format.plannedTime(DateTime.parse('2025-05-12T16:28:12Z'))})\n'
          '(${Format.plannedTime(DateTime.parse('2025-05-12T16:29:12Z'))})';
      expect(_findByKeyInDASTableRowByText(key: timeCellKey, rowText: veveyPlanned), findsOneWidget);
      expect(_findTextInDASTableRowByText(innerText: expectedTimeVeveyPlanned, rowText: veveyPlanned), findsOneWidget);

      await disconnect(tester);
    });

    testWidgets(
      'test auto switch behavior for time cells journey in near future (T9999) with operational and planned times',
      (tester) async {
        await prepareAndStartApp(tester);

        // load train journey by filling out train selection page
        await loadTrainJourney(tester, trainNumber: 'T9999');

        // test if operational time header label is in table
        final expectedCalculatedHeaderLabel = l10n.p_train_journey_table_time_label_new;
        final timeHeader = find.text(expectedCalculatedHeaderLabel);
        expect(timeHeader, findsOneWidget);

        // tap header label to switch to planned times
        await tapElement(tester, timeHeader);

        // test if planned time header label is in table
        final expectedPlannedHeaderLabel = l10n.p_train_journey_table_time_label_planned;
        expect(find.text(expectedPlannedHeaderLabel), findsOneWidget);

        await Future.delayed(Duration(seconds: 11));

        await tester.pumpAndSettle();

        expect(find.text(expectedCalculatedHeaderLabel), findsOneWidget);

        await disconnect(tester);
      },
    );
  });
}

Finder _findByKeyInDASTableRowByText({required Key key, required String rowText}) {
  final row = findDASTableRowByText(rowText);
  expect(row, findsOneWidget);
  return find.descendant(of: row, matching: find.byKey(key));
}

Finder _findTextInDASTableRowByText({required String innerText, required String rowText}) {
  final row = findDASTableRowByText(rowText);
  expect(row, findsOneWidget);
  return find.descendant(of: row, matching: find.text(innerText));
}
