import 'package:app/pages/journey/train_journey/widgets/table/cab_signaling_row.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/track_equipment_cell_body.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../app_test.dart';
import '../util/test_utils.dart';

void main() {
  testWidgets('test if CAB signaling is displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    // load train journey by filling out train selection page
    await loadTrainJourney(tester, trainNumber: 'T1');

    final scrollableFinder = find.byType(AnimatedList);
    expect(scrollableFinder, findsOneWidget);

    // CAB segment with start outside train journey and end at 33.2 km
    await tester.dragUntilVisible(find.text('29.7').first, scrollableFinder, const Offset(0, -50));
    final segment1CABStop = findDASTableRowByText('33.2');
    expect(segment1CABStop, findsOneWidget);
    final segment1CABStopIcon = find.descendant(
      of: segment1CABStop,
      matching: find.byKey(CABSignalingRow.cabSignalingEndIconKey),
    );
    expect(segment1CABStopIcon, findsOneWidget);
    final segment1CABStopSpeed = find.descendant(of: segment1CABStop, matching: find.text('55'));
    expect(segment1CABStopSpeed, findsOneWidget);

    // Track equipment segment without ETCS level 2 should be ignored
    await tester.dragUntilVisible(find.text('12.5').first, scrollableFinder, const Offset(0, -50));
    final etcsL1LSEnd = findDASTableRowByText('10.1');
    expect(etcsL1LSEnd, findsNothing);

    // CAB segment between km 12.5 - km 39.9
    final rowsAtKm12_5 = findDASTableRowByText('12.5');
    expect(rowsAtKm12_5, findsExactly(2));
    final segment2CABStart = rowsAtKm12_5.first; // start should be before other elements at same location
    final segment2CABStartIcon = find.descendant(
      of: segment2CABStart,
      matching: find.byKey(CABSignalingRow.cabSignalingStartIconKey),
    );
    expect(segment2CABStartIcon, findsOneWidget);
    await tester.dragUntilVisible(find.text('75.3'), scrollableFinder, const Offset(0, -50));
    final trackEquipmentTypeChange = findDASTableRowByText('56.8');
    expect(trackEquipmentTypeChange, findsNothing); // no CAB signaling at connecting ETCS L2 segments
    await tester.dragUntilVisible(find.text('41.5'), scrollableFinder, const Offset(0, -50));
    final rothristServicePointRow = findDASTableRowByText('46.2');
    expect(rothristServicePointRow, findsOneWidget); // no CAB signaling at connecting ETCS L2 segments
    final segment2CABEnd = findDASTableRowByText('39.9');
    final segment2CABEndIcon = find.descendant(
      of: segment2CABEnd,
      matching: find.byKey(CABSignalingRow.cabSignalingEndIconKey),
    );
    expect(segment2CABEndIcon, findsOneWidget);
    final segment2CABEndSpeed = find.descendant(of: segment2CABEnd, matching: find.text('80'));
    expect(segment2CABEndSpeed, findsOneWidget);

    // CAB segment with end outside train journey and start at 8.3 km
    await tester.dragUntilVisible(find.text('9.5'), scrollableFinder, const Offset(0, -50));
    final segment3CABStart = findDASTableRowByText('8.3');
    final segment3CABStartIcon = find.descendant(
      of: segment3CABStart,
      matching: find.byKey(CABSignalingRow.cabSignalingStartIconKey),
    );
    expect(segment3CABStartIcon, findsOneWidget);

    await disconnect(tester);
  });

  testWidgets('test if track equipment is displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    // load train journey by filling out train selection page
    await loadTrainJourney(tester, trainNumber: 'T1');

    final scrollableFinder = find.byType(AnimatedList);
    expect(scrollableFinder, findsOneWidget);

    // check ExtendedSpeedReversingPossible from Genève-Aéroport to Gland
    _checkTrackEquipmentOnServicePoint('Genève-Aéroport', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    _checkTrackEquipmentOnServicePoint('Genève', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    _checkTrackEquipmentOnServicePoint('Gland', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    final segment1CABStop = findDASTableRowByText('33.8').last;
    final segment1CABStopTrackEquipment = find.descendant(
      of: segment1CABStop,
      matching: find.byKey(TrackEquipmentCellBody.extendedSpeedReversingPossibleKey),
    );
    expect(segment1CABStopTrackEquipment, findsOneWidget);

    // check two tracks with single track equipment on Gilly-Bursinel
    _checkTrackEquipmentOnServicePoint('Gilly-Bursinel', TrackEquipmentCellBody.twoTracksWithSingleTrackEquipmentKey);

    // check ConventionalSpeedReversingImpossible from Morges to Onnens-Bonvillars
    await tester.dragUntilVisible(find.text('Onnens-Bonvillars'), scrollableFinder, const Offset(0, -50));
    final segment2CABStart = findDASTableRowByText('12.5').first;
    final segment2CABStartTrackEquipment = find.descendant(
      of: segment2CABStart,
      matching: find.byKey(TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey),
    );
    expect(segment2CABStartTrackEquipment, findsOneWidget);
    _checkTrackEquipmentOnServicePoint('Morges', TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey);
    _checkTrackEquipmentOnServicePoint(
      'Yverdon-les-Bains',
      TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey,
    );
    _checkTrackEquipmentOnServicePoint(
      'Onnens-Bonvillars',
      TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey,
    );

    // check ExtendedSpeedReversingPossibleKey from Neuchâtel to Rothrist
    await tester.dragUntilVisible(find.text('Grenchen Süd'), scrollableFinder, const Offset(0, -50));
    _checkTrackEquipmentOnServicePoint(
      'Neuchâtel',
      TrackEquipmentCellBody.extendedSpeedReversingPossibleKey,
      hasConvExtSpeedBorder: true,
    );
    _checkTrackEquipmentOnServicePoint('Biel/Bienne', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    _checkTrackEquipmentOnServicePoint('Lengnau', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    _checkTrackEquipmentOnServicePoint('Grenchen Süd', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    await tester.dragUntilVisible(find.text('Rothrist'), scrollableFinder, const Offset(0, -50));
    _checkTrackEquipmentOnServicePoint('Solothurn', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    _checkTrackEquipmentOnServicePoint('WANZ', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);
    _checkTrackEquipmentOnServicePoint('Rothrist', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);

    // check ExtendedSpeedReversingPossibleKey in Olten
    await tester.dragUntilVisible(find.text('Aarau'), scrollableFinder, const Offset(0, -50));
    _checkTrackEquipmentOnServicePoint(
      'Olten',
      TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey,
      hasConvExtSpeedBorder: true,
    );
    final segment2CABEnd = findDASTableRowByText('39.9').first;
    final segment2CABEndTrackEquipment = find.descendant(
      of: segment2CABEnd,
      matching: find.byKey(TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey),
    );
    expect(segment2CABEndTrackEquipment, findsOneWidget);

    // check ExtendedSpeedReversingImpossibleKey from Zürich HB to Opfikon Süd
    await tester.dragUntilVisible(find.text('Flughafen'), scrollableFinder, const Offset(0, -50));
    final segment3CABStart = findDASTableRowByText('8.3').first;
    final segment3CABStartTrackEquipment = find.descendant(
      of: segment3CABStart,
      matching: find.byKey(TrackEquipmentCellBody.extendedSpeedReversingImpossibleKey),
    );
    expect(segment3CABStartTrackEquipment, findsOneWidget);
    _checkTrackEquipmentOnServicePoint('Zürich HB', TrackEquipmentCellBody.extendedSpeedReversingImpossibleKey);
    _checkTrackEquipmentOnServicePoint('Opfikon Süd', TrackEquipmentCellBody.extendedSpeedReversingImpossibleKey);

    // check ExtendedSpeedReversingImpossibleKey in Flughafen
    _checkTrackEquipmentOnServicePoint('Flughafen', TrackEquipmentCellBody.extendedSpeedReversingPossibleKey);

    await disconnect(tester);
  });

  testWidgets('test if single track without block track equipment is displayed correctly', (tester) async {
    await prepareAndStartApp(tester);

    // load train journey by filling out train selection page
    await loadTrainJourney(tester, trainNumber: 'T10');

    final scrollableFinder = find.byType(AnimatedList);
    expect(scrollableFinder, findsOneWidget);

    // check ExtendedSpeedReversingPossible from Genève-Aéroport to Gland
    _checkTrackEquipmentOnServicePoint('Meiringen', TrackEquipmentCellBody.singleTrackNoBlockKey);
    _checkTrackEquipmentOnServicePoint('Meiringen Alpbach', TrackEquipmentCellBody.singleTrackNoBlockKey);
    _checkTrackEquipmentOnServicePoint('Aareschlucht West', TrackEquipmentCellBody.singleTrackNoBlockKey);
    _checkTrackEquipmentOnServicePoint('Innertkirchen Unterwasser', TrackEquipmentCellBody.singleTrackNoBlockKey);
    _checkTrackEquipmentOnServicePoint('Innertkirchen Grimseltor', TrackEquipmentCellBody.singleTrackNoBlockKey);
    _checkTrackEquipmentOnServicePoint(
      'Innertkirchen Kraftwerk (Bahn)',
      TrackEquipmentCellBody.singleTrackNoBlockKey,
    );

    await disconnect(tester);
  });
}

void _checkTrackEquipmentOnServicePoint(String name, Key expectedKey, {bool hasConvExtSpeedBorder = false}) {
  final servicePointRow = findDASTableRowByText(name);
  final trackEquipment = find.descendant(of: servicePointRow, matching: find.byKey(expectedKey));
  expect(trackEquipment, findsAny);

  final convExtSpeedBorder = find.descendant(
    of: servicePointRow,
    matching: find.byKey(TrackEquipmentCellBody.conventionalExtendedSpeedBorderKey),
  );
  expect(convExtSpeedBorder, hasConvExtSpeedBorder ? findsAny : findsNothing);
}
