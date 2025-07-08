import 'package:app/pages/journey/train_journey/widgets/header/das_chronograph.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_view_model.dart';
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

    final zug = 'Zug';
    final zugStationRow = findDASTableRowByText(zug);
    expect(zugStationRow, findsOneWidget);
    _findTextWithin(zugStationRow, AdvisedSpeedCellBody.zeroSpeedContent);

    await _dragUntilInStickyHeader(tester, zug);

    final baarStationRow = findDASTableRowByText('Baar');
    expect(baarStationRow, findsOneWidget);
    _findTextWithin(baarStationRow, '130');

    final zuerichHb = 'Zürich HB';
    final zuerichHbStationRow = findDASTableRowByText(zuerichHb);
    expect(zuerichHbStationRow, findsOneWidget);
    _findTextWithin(zuerichHbStationRow, '90');

    await _dragUntilInStickyHeader(tester, zuerichHb);

    final zuerichOerlikonStationRow = findDASTableRowByText('Zürich Oerlikon');
    expect(zuerichOerlikonStationRow, findsOneWidget);
    final zuerichAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(zuerichOerlikonStationRow);
    expect(zuerichAdvisedSpeedCell, findsNothing);

    final zuerichAirport = 'Zürich Flughafen';
    final zuerichAirportStationRow = findDASTableRowByText(zuerichAirport);
    expect(zuerichAirportStationRow, findsOneWidget);
    _findTextWithin(zuerichAirportStationRow, '130');

    await _dragUntilInStickyHeader(tester, zuerichAirport);

    final bassersdorfStationRow = findDASTableRowByText('Bassersdorf');
    expect(bassersdorfStationRow, findsOneWidget);
    final bassersdorfAdvisedSpeedCell = _findNonEmptyAdvisedSpeedCellOf(bassersdorfStationRow);
    expect(bassersdorfAdvisedSpeedCell, findsNothing);

    final winterthur = 'Winterthur';
    final winterthurStationRow = findDASTableRowByText(winterthur);
    expect(winterthurStationRow, findsOneWidget);
    _findTextWithin(winterthurStationRow, '80');

    await _dragUntilInStickyHeader(tester, winterthur);

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

    final chronograph = find.byType(DASChronograph);

    // should not display punctuality string
    expect(
      find.descendant(of: chronograph, matching: find.text(PunctualityViewModel.trainIsPunctualString)),
      findsNothing,
    );

    await tester.pumpAndSettle(Duration(milliseconds: 700));

    await waitUntilExists(
      tester,
      find.descendant(of: chronograph, matching: find.byKey(DASChronograph.punctualityTextKey)),
    );

    // event to service point with VPro and delay 40 seconds
    expect(find.descendant(of: chronograph, matching: find.text(fourtySecondsDelay)), findsOneWidget);

    await disconnect(tester);
  });
}

Future<void> _dragUntilInStickyHeader(WidgetTester tester, String station) async {
  final scrollableFinder = find.byType(AnimatedList);
  final stickyHeader = find.byKey(StickyHeader.headerKey);
  await tester.dragUntilVisible(
    find.descendant(of: stickyHeader, matching: find.text(station)),
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
