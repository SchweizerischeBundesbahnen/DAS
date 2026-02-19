import 'package:app/pages/journey/journey_screen/widgets/table/additional_speed_restriction_row.dart';
import 'package:app/widgets/labeled_badge.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test additional speed restriction row is displayed correctly', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T2');

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

  testWidgets('test other non-ASR rows between are colored correctly', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T2');

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
}
