import 'package:app/widgets/modification_icon.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('journeyUpdates_whenChangesReceived_thenDisplaysCorrectly', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T35');

    // check normal rows
    _checkRowModification(tester, ModificationIcon.iconKey, '1.5', false);
    _checkRowModification(tester, ModificationIcon.iconKey, '1.6', false);
    _checkRowModification(tester, ModificationIcon.iconKey, '1.7', false);
    _checkRowModification(tester, ModificationIcon.iconKey, '2.0', false);

    await dragUntilTextInStickyHeader(tester, 'Property Updated');

    // updated rows
    _checkRowModification(tester, ModificationIcon.iconKey, '3.0', true);
    _checkRowModification(tester, ModificationIcon.iconKey, '3.5', true);
    _checkRowModification(tester, ModificationIcon.iconKey, '3.6', true);
    _checkRowModification(tester, ModificationIcon.iconKey, '3.7', true);
    _checkRowModification(tester, ModificationIcon.iconKey, '4.0', true);

    await dragUntilTextInStickyHeader(tester, 'Line Speed Updated');

    _checkRowModification(tester, ModificationIcon.iconKey, '5.0', true);

    // deleted rows
    _checkRowModification(tester, DASTable.strikethroughRowKey, '105.5', true);
    _checkRowModification(tester, DASTable.strikethroughRowKey, '105.4', true);
    _checkRowModification(tester, DASTable.strikethroughRowKey, '105.3', true);
    _checkRowModification(tester, DASTable.strikethroughRowKey, '105.0', true);

    await dragUntilTextInStickyHeader(tester, 'Station Speed Updated');

    _checkRowModification(tester, ModificationIcon.iconKey, '103.0', true);
    // updated but more then 30 days ago rows
    _checkRowModification(tester, ModificationIcon.iconKey, '102.5', false);
    _checkRowModification(tester, ModificationIcon.iconKey, '102.4', false);
    _checkRowModification(tester, ModificationIcon.iconKey, '102.3', false);
    _checkRowModification(tester, ModificationIcon.iconKey, '101.0', false);
    _checkRowModification(tester, ModificationIcon.iconKey, '100.0', false);

    // delete but more then 30 days ago
    expect(findDASTableRowByText('99.6'), findsNothing);
    expect(findDASTableRowByText('99.5'), findsNothing);
    expect(findDASTableRowByText('99.4'), findsNothing);
    expect(findDASTableRowByText('99.3'), findsNothing);

    await disconnect(tester);
  });

  testWidgets('journeyUpdates_whenTrainCharacteristicsUpdated_thenIgnoresUpdate', (tester) async {
    await IntegrationTestApp.start(tester);
    await loadJourney(tester, trainNumber: 'T37');

    final oltenRow = findDASTableRowByText('Olten');
    expect(oltenRow, findsNothing);
    expect(findDASTableColumnByText('R150'), findsOneWidget);

    // wait for JP update with new SP (added service point Olten) and TC (N180)
    await waitUntilExists(tester, oltenRow, maxWaitSeconds: 3);
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
