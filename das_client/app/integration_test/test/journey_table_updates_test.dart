import 'package:app/pages/journey/journey_screen/header/widgets/extended_menu.dart';
import 'package:app/pages/journey/journey_screen/reduced_overview/widgets/reduced_journey_table.dart';
import 'package:app/widgets/modification_icon.dart';
import 'package:app/widgets/table/das_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../integration/integration_test_app.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('journeyUpdates_whenChangesReceived_thenDisplaysCorrectly|rCW5QKoQdUwtfxVEEIHR|tests:241', (
    tester,
  ) async {
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

  testWidgets(
    'journeyUpdates_whenModificationsAcknowledged_thenHandlesAcknowledgeUndoAndVisibility|qcfAfzgvqun2EA6aOH8Z|tests:2218',
    (tester) async {
      await IntegrationTestApp.start(tester);
      await loadJourney(tester, trainNumber: 'T35');

      await dragUntilTextInStickyHeader(tester, 'Property Updated');

      // Initially, rows 3.0 and 3.5 show modification icons
      _checkRowModification(tester, ModificationIcon.iconKey, '3.0', true);
      _checkRowModification(tester, ModificationIcon.iconKey, '3.5', true);

      // 1. Acknowledge row 3.0 by double-tapping
      await _doubleTap(tester, findDASTableRowByText('3.0'));

      // Verify toast is shown with undo action
      expect(find.text(l10n.w_journey_table_modification_acknowledged), findsOneWidget);
      final undoButton = find.text(l10n.w_journey_table_modification_acknowledged_undo);
      expect(undoButton, findsOneWidget);

      // Verify modification icon for 3.0 is hidden
      _checkRowModification(tester, ModificationIcon.iconKey, '3.0', false);

      // 2. Test Undo
      await tapElement(tester, undoButton);
      _checkRowModification(tester, ModificationIcon.iconKey, '3.0', true);

      // 3. Acknowledge row 3.0 again and acknowledge row C1 Signal
      await _doubleTap(tester, findDASTableRowByText('3.0'));
      _checkRowModification(tester, ModificationIcon.iconKey, '3.0', false);

      await _doubleTap(tester, findDASTableRowByText('C1'));
      _checkRowModification(tester, ModificationIcon.iconKey, 'C1', false);

      await dragUntilTextInStickyHeader(tester, 'Line Speed Updated');
      expect(findDASTableRowByText('D1'), findsOne);
      await _doubleTap(tester, findDASTableRowByText('D1'));
      expect(findDASTableRowByText('D1'), findsNothing);

      // 4. Test Reduced Overview (Reduzierte Ansicht)
      await openReducedJourneyMenu(tester);

      final reducedTable = find.byType(ReducedJourneyTable);
      expect(reducedTable, findsOneWidget);

      // Row 3.0 (mandatory stopping point) is present, but modification icon is hidden because it was acknowledged
      _checkReducedRowModification(ModificationIcon.iconKey, 'Property Updated', false);

      // Row C1 (optional signal) was acknowledged, so it is filtered out from the reduced overview
      expect(_findRowInReducedJourney('C1'), findsNothing);

      // Row K Ausf. was not acknowledged, so it is present with modification icon
      _checkReducedRowModification(ModificationIcon.iconKey, 'K Ausf.', true);

      // Row D1 (optional signal) was acknowledged, so it is filtered out from the reduced overview
      expect(_findRowInReducedJourney('D1'), findsNothing);

      // Close reduced overview
      final closeBottomSheetButton = find.byKey(SBBBottomSheet.closeButtonKey);
      await tapElement(tester, closeBottomSheetButton);

      // 5. Test "Änderungen anzeigen" in Extended Menu
      await openExtendedMenu(tester);

      final toggleSwitch = find.byKey(ExtendedMenu.acknowledgedModificationsItemKey);
      expect(toggleSwitch, findsOneWidget);
      await tapElement(tester, toggleSwitch);

      expect(findDASTableRowByText('D1'), findsOne);

      final scrollableFinder = find.byType(AnimatedList);
      await tester.dragUntilVisible(find.text('km 1.7'), scrollableFinder, Offset(0, 50));

      // In main table: acknowledged modifications are visible again
      _checkRowModification(tester, ModificationIcon.iconKey, '3.0', true);
      _checkRowModification(tester, ModificationIcon.iconKey, '3.5', true);

      // In reduced overview: acknowledged modifications are displayed again
      await openReducedJourneyMenu(tester);

      _checkReducedRowModification(ModificationIcon.iconKey, 'Property Updated', true);
      _checkReducedRowModification(ModificationIcon.iconKey, 'C1', true);
      expect(_findRowInReducedJourney('D1'), findsOneWidget);

      await disconnect(tester);
    },
  );

  testWidgets('journeyUpdates_whenTrainCharacteristicsUpdated_thenIgnoresUpdate|ld7g7OsSEKkPbbGjJ5aM|tests:1416', (
    tester,
  ) async {
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

Future<void> _doubleTap(WidgetTester tester, FinderBase<Element> element) async {
  await tester.tap(element);
  await tester.pump(const Duration(milliseconds: 50));
  await tester.tap(element);
  await tester.pumpAndSettle();
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

Finder _findRowInReducedJourney(String text) {
  final reducedJourneyTable = find.byKey(ReducedJourneyTable.reducedJourneyTableKey);
  return find.descendant(
    of: reducedJourneyTable,
    matching: find.ancestor(of: find.text(text), matching: find.byKey(DASTable.rowKey)),
  );
}

void _checkReducedRowModification(Key modificationKey, String rowText, bool exists) {
  final modifiedRow = _findRowInReducedJourney(rowText);
  expect(modifiedRow, findsAny);

  final modificationWidget = find.descendant(
    of: modifiedRow.first,
    matching: find.byKey(modificationKey),
  );
  expect(modificationWidget, exists ? findsOneWidget : findsNothing);
}
