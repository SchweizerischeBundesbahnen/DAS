import 'package:app/pages/journey/train_journey/widgets/header/time_container.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/advised_speed_cell_body.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test calculated speeds are displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    await loadTrainJourney(tester, trainNumber: 'T23');

    // do not get disrupted by events
    await pauseAutomaticAdvancement(tester);
    await tester.pumpAndSettle(Duration(milliseconds: 100));

    final scrollableFinder = find.byType(AnimatedList);

    final ebikonStationRow = findDASTableRowByText('Ebikon');
    expect(ebikonStationRow, findsOneWidget);
    final ebikonAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(ebikonStationRow);
    expect(ebikonAdvisedSpeedCell, findsNothing);

    final buchrainStationRow = findDASTableRowByText('Buchrain');
    expect(buchrainStationRow, findsOneWidget);
    _findTextWithin(buchrainStationRow, '110');

    final rotkreuxStationRow = findDASTableRowByText('Rotkreuz');
    expect(rotkreuxStationRow, findsOneWidget);
    _findTextWithin(rotkreuxStationRow, '130');

    final zugStationRow = findDASTableRowByText('Zug');
    expect(zugStationRow, findsOneWidget);
    _findTextWithin(zugStationRow, AdvisedSpeedCellBody.zeroSpeedContent);

    final baarStationRow = findDASTableRowByText('Baar');
    expect(baarStationRow, findsOneWidget);
    _findTextWithin(baarStationRow, '130');

    final zuerichHbStationRow = findDASTableRowByText('Zürich HB');
    expect(zuerichHbStationRow, findsOneWidget);
    _findTextWithin(zuerichHbStationRow, '90');

    final zuerichOerlikonStationRow = findDASTableRowByText('Zürich Oerlikon');
    expect(zuerichOerlikonStationRow, findsOneWidget);
    final zuerichAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(zuerichOerlikonStationRow);
    expect(zuerichAdvisedSpeedCell, findsNothing);

    // scroll to see lower stations
    await tester.dragUntilVisible(find.text('Konstanz'), scrollableFinder, const Offset(0, -100));

    final zuerichAirportStationRow = findDASTableRowByText('Zürich Flughafen');
    expect(zuerichAirportStationRow, findsOneWidget);
    _findTextWithin(zuerichAirportStationRow, '130');

    final bassersdorfStationRow = findDASTableRowByText('Bassersdorf');
    expect(bassersdorfStationRow, findsOneWidget);
    final bassersdorfAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(bassersdorfStationRow);
    expect(bassersdorfAdvisedSpeedCell, findsNothing);

    final winterthurStationRow = findDASTableRowByText('Winterthur');
    expect(winterthurStationRow, findsOneWidget);
    _findTextWithin(winterthurStationRow, '80');

    final frauenfeldStationRow = findDASTableRowByText('Frauenfeld');
    expect(frauenfeldStationRow, findsOneWidget);
    final frauenfeldAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(frauenfeldStationRow);
    expect(frauenfeldAdvisedSpeedCell, findsNothing);

    final weinfeldenStationRow = findDASTableRowByText('Weinfelden');
    expect(weinfeldenStationRow, findsOneWidget);
    final weinfeldenAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(weinfeldenStationRow);
    expect(weinfeldenAdvisedSpeedCell, findsNothing);

    final kreuzlingenStationRow = findDASTableRowByText('Kreuzlingen');
    expect(kreuzlingenStationRow, findsOneWidget);
    _findTextWithin(kreuzlingenStationRow, AdvisedSpeedCellBody.zeroSpeedContent);

    final konstanzStationRow = findDASTableRowByText('Konstanz');
    expect(konstanzStationRow, findsOneWidget);
    final konstanzAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(konstanzStationRow);
    expect(konstanzAdvisedSpeedCell, findsNothing);

    await disconnect(tester);
  });

  testWidgets('test calculated speeds are displayed correctly in sticky header', (tester) async {
    await prepareAndStartApp(tester);

    await loadTrainJourney(tester, trainNumber: 'T23');

    // do not get disrupted by events
    await pauseAutomaticAdvancement(tester);
    await tester.pumpAndSettle(Duration(milliseconds: 100));

    await _dragUntilInStickyHeader(tester, 'Thalwil');

    // Oerlikon ---------

    final oerlikon = 'Zürich Oerlikon';
    final zuerichOerlikonStationRow = findDASTableRowByText(oerlikon);
    expect(zuerichOerlikonStationRow, findsOneWidget);
    final zuerichOerlikonAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(zuerichOerlikonStationRow);
    expect(zuerichOerlikonAdvisedSpeedCell, findsNothing);

    await _dragUntilInStickyHeader(tester, oerlikon);

    // filled from Zürich HB
    expect(zuerichOerlikonStationRow, findsOneWidget);
    _findTextWithin(zuerichOerlikonStationRow, '90');

    // Zürich Flughafen -------

    const zurichAirport = 'Zürich Flughafen';
    final zrhStationRow = findDASTableRowByText(zurichAirport);
    expect(zrhStationRow, findsOneWidget);
    _findTextWithin(zrhStationRow, '130');

    await _dragUntilInStickyHeader(tester, zurichAirport);

    // filled with line speed from Zürich HB
    expect(zrhStationRow, findsOneWidget);
    _findTextWithin(zrhStationRow, '110');

    // Frauenfeld -------

    const frauenfeld = 'Frauenfeld';
    final frauenfeldStationRow = findDASTableRowByText(frauenfeld);
    expect(frauenfeldStationRow, findsOneWidget);
    final frauenfeldAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(frauenfeldStationRow);
    expect(frauenfeldAdvisedSpeedCell, findsNothing);

    await _dragUntilInStickyHeader(tester, frauenfeld);

    // filled with line speed from Frauenfeld
    expect(frauenfeldStationRow, findsOneWidget);
    _findTextWithin(frauenfeldStationRow, '70');

    await disconnect(tester);
  });

  testWidgets('test do not display punctuality if no vpro speed in current position', (tester) async {
    await prepareAndStartApp(tester);

    await loadTrainJourney(tester, trainNumber: 'T23');

    const fourtySecondsDelay = '+00:40';

    final timeContainer = find.byType(TimeContainer);

    // should not display punctuality string
    expect(find.descendant(of: timeContainer, matching: find.text(TimeContainer.trainIsPunctualString)), findsNothing);

    await tester.pumpAndSettle(Duration(milliseconds: 700));

    // first event to service point without VPro
    expect(find.descendant(of: timeContainer, matching: find.text(TimeContainer.trainIsPunctualString)), findsNothing);

    await tester.pumpAndSettle(Duration(seconds: 3));

    // event to service point with VPro and delay 40 seconds
    expect(find.descendant(of: timeContainer, matching: find.text(fourtySecondsDelay)), findsOneWidget);

    await disconnect(tester);
  });
}

Future<void> _dragUntilInStickyHeader(WidgetTester tester, String bassersdorf) async {
  final scrollableFinder = find.byType(AnimatedList);
  final stickyHeader = find.byKey(StickyHeader.headerKey);
  await tester.dragUntilVisible(
    find.descendant(of: stickyHeader, matching: find.text(bassersdorf)),
    scrollableFinder,
    const Offset(0, -50),
    maxIteration: 100,
  );
  await tester.pumpAndSettle();
}

void _findTextWithin(Finder buchrainStationRow, String s) {
  final speedCell = find.descendant(
    of: buchrainStationRow,
    matching: find.byKey(AdvisedSpeedCellBody.generalKey),
  );
  final speed = find.descendant(of: speedCell, matching: find.text(s));
  expect(speed, findsOneWidget);
}

Finder _findNonEmptyAdvisedSpeedCellOf(Finder luzernStationRow) {
  return find.descendant(
    of: luzernStationRow,
    matching: find.byKey(AdvisedSpeedCellBody.nonEmptyKey),
  );
}
