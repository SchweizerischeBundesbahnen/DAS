import 'package:app/pages/journey/journey_table/widgets/table/service_point_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test station signs are displayed', (tester) async {
    await prepareAndStartApp(tester);

    await loadJourney(tester, trainNumber: 'T21');

    final scrollableFinder = find.byType(AnimatedList);

    expect(find.byKey(Key(StationSign.deadendStation.name)), findsAtLeast(4));
    expect(find.byKey(Key(StationSign.noExitSignal.name)), findsNWidgets(2));
    expect(find.byKey(Key(StationSign.noEntrySignal.name)), findsNWidgets(1));
    expect(find.byKey(Key(StationSign.noEntryExitSignal.name)), findsNWidgets(1));
    expect(find.byKey(Key(StationSign.entryStationWithoutRailFreeAccess.name)), findsNWidgets(1));

    await tester.dragUntilVisible(find.text('Lausanne'), scrollableFinder, const Offset(0, -50));

    expect(find.byKey(Key(StationSign.openLevelCrossingBeforeExitSignal.name)), findsNWidgets(2));

    await tester.dragUntilVisible(find.text('Aigle'), scrollableFinder, const Offset(0, -50));

    expect(find.byKey(Key(StationSign.entryOccupiedTrack.name)), findsNWidgets(1));

    await disconnect(tester);
  });

  testWidgets('test station properties are displayed', (tester) async {
    await prepareAndStartApp(tester);

    await loadJourney(tester, trainNumber: 'T21');

    final geneveRow = findDASTableRowByText('Genève');
    expect(find.descendant(of: geneveRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);
    expect(find.descendant(of: geneveRow, matching: find.text('A')), findsOneWidget);
    expect(find.descendant(of: geneveRow, matching: find.text('55')), findsOneWidget);

    final nyonRow = findDASTableRowByText('Nyon');
    expect(find.descendant(of: nyonRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);
    expect(find.descendant(of: nyonRow, matching: find.byKey(Key(StationSign.noEntryExitSignal.name))), findsOneWidget);
    expect(find.descendant(of: nyonRow, matching: find.text('60')), findsOneWidget);
    expect(find.descendant(of: nyonRow, matching: find.text('70')), findsOneWidget);
    expect(find.descendant(of: nyonRow, matching: find.text(' / ')), findsOneWidget);

    Finder scrollableFinder = find.byType(AnimatedList);
    await tester.dragUntilVisible(find.text('Vevey'), scrollableFinder, const Offset(0, -50));

    final veveyRow = findDASTableRowByText('Vevey');
    expect(find.text('Vevey'), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.text('via Stammlinie')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.text('35')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.text('A')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(ServicePointRow.reducedSpeedKey)), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);

    scrollableFinder = find.byType(AnimatedList);
    await tester.dragUntilVisible(find.text('Aigle'), scrollableFinder, const Offset(0, -50));

    final aigleRow = findDASTableRowByText('Aigle');
    expect(
      find.descendant(of: aigleRow, matching: find.byKey(Key(StationSign.entryOccupiedTrack.name))),
      findsOneWidget,
    );

    await disconnect(tester);
  });

  testWidgets('test station properties are displayed depending on TrainSeries', (tester) async {
    await prepareAndStartApp(tester);

    await loadJourney(tester, trainNumber: 'T21');

    var geneveRow = findDASTableRowByText('Genève');
    expect(find.descendant(of: geneveRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);

    final scrollableFinder = find.byType(AnimatedList);
    await tester.dragUntilVisible(find.text('Vevey'), scrollableFinder, const Offset(0, -50));

    var veveyRow = findDASTableRowByText('Vevey');
    expect(find.descendant(of: veveyRow, matching: find.text('via Stammlinie')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(ServicePointRow.reducedSpeedKey)), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);

    await selectBreakSeries(tester, breakSeries: 'R115');

    geneveRow = findDASTableRowByText('Genève');
    expect(find.descendant(of: geneveRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsNothing);

    await tester.dragUntilVisible(find.text('Vevey'), scrollableFinder, const Offset(0, -50));

    veveyRow = findDASTableRowByText('Vevey');
    expect(find.descendant(of: veveyRow, matching: find.text('via Stammlinie')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(ServicePointRow.reducedSpeedKey)), findsNothing);
    expect(find.descendant(of: veveyRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);

    await disconnect(tester);
  });
}
