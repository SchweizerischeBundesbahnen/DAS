import 'package:app/widgets/modification_indicator.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test journey changes are displayed correctly', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T35');

    // check normal rows
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '1.5', false);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '1.6', false);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '1.7', false);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '2.0', false);

    await dragUntilTextInStickyHeader(tester, 'Property Updated');

    // updated rows
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '3.0', true);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '3.5', true);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '3.6', true);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '3.7', true);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '4.0', true);

    await dragUntilTextInStickyHeader(tester, 'Line Speed Updated');

    _checkRowModification(tester, ModificationIndicator.indicatorKey, '5.0', true);

    // deleted rows
    _checkRowModification(tester, DASTable.strikethroughRowKey, '105.5', true);
    _checkRowModification(tester, DASTable.strikethroughRowKey, '105.4', true);
    _checkRowModification(tester, DASTable.strikethroughRowKey, '105.3', true);
    _checkRowModification(tester, DASTable.strikethroughRowKey, '105.0', true);

    await dragUntilTextInStickyHeader(tester, 'Station Speed Updated');

    _checkRowModification(tester, ModificationIndicator.indicatorKey, '103.0', true);
    // updated but more then 30 days ago rows
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '102.5', false);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '102.4', false);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '102.3', false);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '101.0', false);
    _checkRowModification(tester, ModificationIndicator.indicatorKey, '100.0', false);

    // delete but more then 30 days ago
    expect(findDASTableRowByText('99.6'), findsNothing);
    expect(findDASTableRowByText('99.5'), findsNothing);
    expect(findDASTableRowByText('99.4'), findsNothing);
    expect(findDASTableRowByText('99.3'), findsNothing);

    await disconnect(tester);
  });

  testWidgets('test ignore train characteristics update', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T37');

    final oltenRow = findDASTableRowByText('Olten');
    expect(oltenRow, findsNothing);
    expect(findDASTableColumnByText('R150'), findsOneWidget);

    // wait for JP update with new SP (added service point Olten) and TC (N180)
    waitUntilExists(tester, oltenRow, maxWaitSeconds: 3);
    expect(findDASTableColumnByText('N180'), findsNothing);
    expect(findDASTableColumnByText('R150'), findsOneWidget);
  });
}

void _checkRowModification(WidgetTester tester, Key modificationKey, String rowText, bool exists) {
  final modifiedRow = findDASTableRowByText(rowText);
  expect(modifiedRow, findsOneWidget);

  final modificationWidget = find.descendant(
    of: modifiedRow,
    matching: find.byKey(modificationKey),
  );
  expect(modificationWidget, exists ? findsOneWidget : findsNothing);
}
