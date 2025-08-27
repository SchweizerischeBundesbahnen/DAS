import 'package:app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:sfera/component.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  patrolTest('test station signs are displayed', (tester) async {
    await prepareAndStartApp(tester.tester);

    await loadTrainJourney(tester.tester, trainNumber: 'T21');

    expect(find.byKey(Key(StationSign.deadendStation.name)), findsNWidgets(5));
    expect(find.byKey(Key(StationSign.noExitSignal.name)), findsNWidgets(2));
    expect(find.byKey(Key(StationSign.noEntrySignal.name)), findsNWidgets(1));
    expect(find.byKey(Key(StationSign.noEntryExitSignal.name)), findsNWidgets(1));
    expect(find.byKey(Key(StationSign.entryStationWithoutRailFreeAccess.name)), findsNWidgets(1));
    expect(find.byKey(Key(StationSign.openLevelCrossingBeforeExitSignal.name)), findsNWidgets(2));

    final scrollableFinder = find.byType(AnimatedList);
    await tester.tester.dragUntilVisible(find.text('Aigle'), scrollableFinder, const Offset(0, -50));

    expect(find.byKey(Key(StationSign.entryOccupiedTrack.name)), findsNWidgets(1));

    await disconnect(tester.tester);
  });

  patrolTest('test station properties are displayed', (tester) async {
    await prepareAndStartApp(tester.tester);

    await loadTrainJourney(tester.tester, trainNumber: 'T21');

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

    final veveyRow = findDASTableRowByText('Vevey');
    expect(find.descendant(of: veveyRow, matching: find.text('via Stammlinie')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.text('35')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.text('A')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(ServicePointRow.reducedSpeedKey)), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);

    final scrollableFinder = find.byType(AnimatedList);
    await tester.tester.dragUntilVisible(find.text('Aigle'), scrollableFinder, const Offset(0, -50));

    final aigleRow = findDASTableRowByText('Aigle');
    expect(
      find.descendant(of: aigleRow, matching: find.byKey(Key(StationSign.entryOccupiedTrack.name))),
      findsOneWidget,
    );

    await disconnect(tester.tester);
  });

  patrolTest('test station properties are displayed depending on TrainSeries', (tester) async {
    await prepareAndStartApp(tester.tester);

    await loadTrainJourney(tester.tester, trainNumber: 'T21');

    var geneveRow = findDASTableRowByText('Genève');
    expect(find.descendant(of: geneveRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);

    var veveyRow = findDASTableRowByText('Vevey');
    expect(find.descendant(of: veveyRow, matching: find.text('via Stammlinie')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(ServicePointRow.reducedSpeedKey)), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);

    await selectBreakSeries(tester.tester, breakSeries: 'R115');

    geneveRow = findDASTableRowByText('Genève');
    expect(find.descendant(of: geneveRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsNothing);

    veveyRow = findDASTableRowByText('Vevey');
    expect(find.descendant(of: veveyRow, matching: find.text('via Stammlinie')), findsOneWidget);
    expect(find.descendant(of: veveyRow, matching: find.byKey(ServicePointRow.reducedSpeedKey)), findsNothing);
    expect(find.descendant(of: veveyRow, matching: find.byKey(Key(StationSign.deadendStation.name))), findsOneWidget);

    await disconnect(tester.tester);
  });
}
