import 'package:app/pages/journey/journey_screen/header/view_model/chronograph_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/chronograph_header_box.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/cells/calculated_speed_cell_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test calculated speeds are displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    await loadJourney(tester, trainNumber: 'T23M');

    final ebikonStationRow = findDASTableRowByText('Ebikon');
    expect(ebikonStationRow, findsOneWidget);
    final ebikonAdvisedSpeedCell = _findNonEmptyCalculatedSpeedCellOf(ebikonStationRow);
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
    _findTextWithin(zugStationRow, CalculatedSpeedCellBody.zeroSpeedContent);

    await dragUntilTextInStickyHeader(tester, zug);

    final baarStationRow = findDASTableRowByText('Baar');
    expect(baarStationRow, findsOneWidget);
    _findTextWithin(baarStationRow, '130');

    final zuerichHb = 'Zürich HB';
    final zuerichHbStationRow = findDASTableRowByText(zuerichHb);
    expect(zuerichHbStationRow, findsOneWidget);
    _findTextWithin(zuerichHbStationRow, '90');

    await dragUntilTextInStickyHeader(tester, zuerichHb);

    final zurichOerlikon = 'Zürich Oerlikon';
    final zuerichOerlikonStationRow = findDASTableRowByText(zurichOerlikon);
    expect(zuerichOerlikonStationRow, findsOneWidget);

    await dragUntilTextInStickyHeader(tester, zurichOerlikon);
    final zuerichAdvisedSpeedCell = _findNonEmptyCalculatedSpeedCellOf(zuerichOerlikonStationRow);
    expect(zuerichAdvisedSpeedCell, findsOne);

    final bassersdorf = 'Bassersdorf';
    final bassersdorfStationRow = findDASTableRowByText(bassersdorf);
    expect(bassersdorfStationRow, findsOneWidget);

    // Basserdorf should not yet have a calculated speed
    expect(_findNonEmptyCalculatedSpeedCellOf(bassersdorfStationRow), findsNothing);

    final zuerichAirport = 'Zürich Flughafen';
    final zuerichAirportStationRow = findDASTableRowByText(zuerichAirport);
    expect(zuerichAirportStationRow, findsOneWidget);
    _findTextWithin(zuerichAirportStationRow, '110');

    await dragUntilTextInStickyHeader(tester, bassersdorf);
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    // Basserdorf should now have a calculated speed
    expect(_findNonEmptyCalculatedSpeedCellOf(bassersdorfStationRow), findsAny);

    final winterthur = 'Winterthur';
    final winterthurStationRow = findDASTableRowByText(winterthur);
    expect(winterthurStationRow, findsOneWidget);
    _findTextWithin(winterthurStationRow, '80');

    await dragUntilTextInStickyHeader(tester, winterthur);

    final frauenfeldStationRow = findDASTableRowByText('Frauenfeld');
    expect(frauenfeldStationRow, findsOneWidget);
    final frauenfeldAdvisedSpeedCell = _findNonEmptyCalculatedSpeedCellOf(frauenfeldStationRow);
    expect(frauenfeldAdvisedSpeedCell, findsNothing);

    final weinfeldenStationRow = findDASTableRowByText('Weinfelden');
    expect(weinfeldenStationRow, findsOneWidget);
    final weinfeldenAdvisedSpeedCell = _findNonEmptyCalculatedSpeedCellOf(weinfeldenStationRow);
    expect(weinfeldenAdvisedSpeedCell, findsNothing);

    final kreuzlingenStationRow = findDASTableRowByText('Kreuzlingen');
    expect(kreuzlingenStationRow, findsOneWidget);
    _findTextWithin(kreuzlingenStationRow, CalculatedSpeedCellBody.zeroSpeedContent);

    final konstanzStationRow = findDASTableRowByText('Konstanz');
    expect(konstanzStationRow, findsOneWidget);
    final konstanzAdvisedSpeedCell = _findNonEmptyCalculatedSpeedCellOf(konstanzStationRow);
    expect(konstanzAdvisedSpeedCell, findsNothing);

    await disconnect(tester);
  });

  testWidgets('test calculated speeds are displayed correctly in sticky header', (tester) async {
    await prepareAndStartApp(tester);

    await loadJourney(tester, trainNumber: 'T23M');

    await dragUntilTextInStickyHeader(tester, 'Thalwil');

    // Oerlikon ---------

    final oerlikon = 'Zürich Oerlikon';
    final zuerichOerlikonStationRow = findDASTableRowByText(oerlikon);
    expect(zuerichOerlikonStationRow, findsOneWidget);
    final zuerichOerlikonAdvisedSpeedCell = _findNonEmptyCalculatedSpeedCellOf(zuerichOerlikonStationRow);
    expect(zuerichOerlikonAdvisedSpeedCell, findsNothing);

    await dragUntilTextInStickyHeader(tester, oerlikon);

    // only show once in sticky header
    expect(zuerichOerlikonStationRow, findsOneWidget);
    _findTextWithin(zuerichOerlikonStationRow, '90');

    // Zürich Flughafen -------

    const zurichAirport = 'Zürich Flughafen';
    final zrhStationRow = findDASTableRowByText(zurichAirport);

    // filled with line speed from Zürich HB
    expect(zrhStationRow, findsOneWidget);
    _findTextWithin(zrhStationRow, '110');

    // Bassersdorf -------

    const bassersdorf = 'Bassersdorf';
    final bassersdorfStationRow = findDASTableRowByText(bassersdorf);
    expect(bassersdorfStationRow, findsOneWidget);
    final bassersdorfAdvisedSpeedCell = _findNonEmptyCalculatedSpeedCellOf(bassersdorfStationRow);
    expect(bassersdorfAdvisedSpeedCell, findsNothing);

    await dragUntilTextInStickyHeader(tester, bassersdorf);

    // filled with line speed from Zürich HB
    expect(bassersdorfStationRow, findsOneWidget);
    _findTextWithin(bassersdorfStationRow, '110');

    await disconnect(tester);
  });

  testWidgets('test do not display chronograph punctuality if no vpro speed in current position', (tester) async {
    await prepareAndStartApp(tester);

    await loadJourney(tester, trainNumber: 'T23');

    final chronograph = find.byType(ChronographHeaderBox);

    // should not display chronograph string
    expect(
      find.descendant(of: chronograph, matching: find.text(ChronographViewModel.trainIsPunctualString)),
      findsNothing,
    );

    // event to service point with VPro and delay 10 seconds
    const fourtySecondsDelay = '+00:40';
    await waitUntilExists(
      tester,
      find.descendant(of: chronograph, matching: find.text(fourtySecondsDelay)),
    );

    await disconnect(tester);
  });

  testWidgets('test calculated speed is reduced to line speed and displayed in different color', (tester) async {
    await prepareAndStartApp(tester);

    await loadJourney(tester, trainNumber: 'T23M');

    await dragUntilTextInStickyHeader(tester, 'Buchrain');

    // find reduced speed in Rotkreuz
    final rotkreuzStationRow = findDASTableRowByText('Rotkreuz');
    expect(rotkreuzStationRow, findsOneWidget);
    _findTextWithin(rotkreuzStationRow, '130');

    // should be in cement because it is in the next stop
    final textWidget = tester.widget<Text>(
      find.descendant(of: rotkreuzStationRow, matching: find.byKey(CalculatedSpeedCellBody.nonEmptyKey)),
    );
    expect(textWidget.style?.color, equals(SBBColors.cement));

    await disconnect(tester);
  });
}

void _findTextWithin(Finder baseFinder, String s) {
  final speedCell = find.descendant(
    of: baseFinder,
    matching: find.byKey(CalculatedSpeedCellBody.generalKey),
  );
  final speed = find.descendant(of: speedCell, matching: find.text(s));
  expect(speed, findsOneWidget);
}

Finder _findNonEmptyCalculatedSpeedCellOf(Finder baseFinder) {
  return find.descendant(
    of: baseFinder,
    matching: find.byKey(CalculatedSpeedCellBody.nonEmptyKey),
  );
}
