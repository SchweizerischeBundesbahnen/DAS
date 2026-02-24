import 'package:app/pages/journey/journey_screen/widgets/table/balise_level_crossing_group_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/balise_row.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/level_crossing_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test balise multiple level crossings', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T7');

    final baliseMultiLevelCrossing = findDASTableRowByText('(2 ${l10n.p_journey_table_level_crossing})');
    expect(baliseMultiLevelCrossing, findsOneWidget);

    final baliseIcon = find.descendant(
      of: baliseMultiLevelCrossing,
      matching: find.byKey(BaliseLevelCrossingGroupRow.iconBaliseKey),
    );
    expect(baliseIcon, findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('test balise and level crossing groups expand / collapse', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T7');

    final groupOf5BaliseRow = findDASTableRowByText('41.6');
    expect(groupOf5BaliseRow, findsOneWidget);

    final countText = find.descendant(of: groupOf5BaliseRow, matching: find.text('5'));
    expect(countText, findsOneWidget);

    final levelCrossingText = find.descendant(
      of: groupOf5BaliseRow,
      matching: find.text(l10n.p_journey_table_level_crossing),
    );
    expect(levelCrossingText, findsOneWidget);

    // only in ETCS level 2
    final levelCrossingIcon = find.descendant(
      of: groupOf5BaliseRow,
      matching: find.byKey(BaliseLevelCrossingGroupRow.iconLevelCrossingKey),
    );
    expect(levelCrossingIcon, findsNothing);

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

    // only in ETCS level 2
    final levelCrossingRowIcon = find.descendant(
      of: groupOf5BaliseRow,
      matching: find.byKey(LevelCrossingRow.iconLevelCrossingKey),
    );
    expect(levelCrossingRowIcon, findsNothing);

    // collapse group
    await tapElement(tester, groupOf5BaliseRow);

    detailRowBalise = findDASTableRowByText('41.552');
    detailRowLevelCrossing = findDASTableRowByText('41.492');

    expect(detailRowLevelCrossing, findsNothing);
    expect(detailRowBalise, findsNothing);

    await disconnect(tester);
  });

  testWidgets('test level crossing in ETCS level 2 section', (tester) async {
    await prepareAndStartApp(tester);
    await loadJourney(tester, trainNumber: 'T7');

    final scrollableFinder = find.byType(AnimatedList);
    expect(scrollableFinder, findsOneWidget);

    await tester.dragUntilVisible(find.text('Rothrist'), scrollableFinder, const Offset(0, -50));

    final levelCrossingGroup = findDASTableRowByText('74.7');

    final levelCrossingGroupIcon = find.descendant(
      of: levelCrossingGroup,
      matching: find.byKey(BaliseLevelCrossingGroupRow.iconLevelCrossingKey),
    );
    expect(levelCrossingGroupIcon, findsOneWidget);

    // only in non-ETCS level 2 sections
    final levelCrossingGroupText = find.descendant(
      of: levelCrossingGroup,
      matching: find.text(l10n.p_journey_table_level_crossing),
    );
    expect(levelCrossingGroupText, findsNothing);

    // expand group
    await tapElement(tester, levelCrossingGroup);
    await tester.dragUntilVisible(find.text('Rothrist'), scrollableFinder, const Offset(0, -50));

    final detailRowLevelCrossing = findDASTableRowByText('74.700');
    expect(detailRowLevelCrossing, findsOneWidget);

    final levelCrossingIcon = find.descendant(
      of: detailRowLevelCrossing,
      matching: find.byKey(LevelCrossingRow.iconLevelCrossingKey),
    );
    expect(levelCrossingIcon, findsOneWidget);

    // only in non-ETCS level 2 sections
    final levelCrossingText = find.descendant(
      of: detailRowLevelCrossing,
      matching: find.text(l10n.p_journey_table_level_crossing),
    );
    expect(levelCrossingText, findsNothing);

    await disconnect(tester);
  });
}
