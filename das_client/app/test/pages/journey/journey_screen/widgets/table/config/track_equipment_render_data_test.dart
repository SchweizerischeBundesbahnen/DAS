import 'package:app/pages/journey/journey_screen/widgets/table/cell_row_builder.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/track_equipment_render_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/cab_signaling.dart';
import 'package:sfera/src/model/journey/connection_track.dart';
import 'package:sfera/src/model/journey/curve_point.dart';
import 'package:sfera/src/model/journey/journey.dart';
import 'package:sfera/src/model/journey/level_crossing.dart';
import 'package:sfera/src/model/journey/metadata.dart';
import 'package:sfera/src/model/journey/service_point.dart';
import 'package:sfera/src/model/journey/signal.dart';
import 'package:sfera/src/model/journey/track_equipment_segment.dart';

void main() {
  test('test CAB signaling start and end', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(
        nonStandardTrackEquipmentSegments: [
          _trackEquipmentSegment(.etcsL2ExtSpeedReversingImpossible, 0, 9999),
        ],
      ),
      data: [
        CABSignaling(order: 100, kilometre: [], isStart: true),
        Signal(order: 200, kilometre: []),
        CABSignaling(order: 300, kilometre: [], isStart: false),
      ],
    );

    // WHEN
    final cabSignalingStart = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 0);
    final signal = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 1);
    final cabSignalingEnd = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 2);

    // THEN
    expect(cabSignalingStart, isNotNull);
    expect(cabSignalingStart!.isStart, isTrue);
    expect(cabSignalingStart.isEnd, isFalse);
    expect(signal, isNotNull);
    expect(signal!.isStart, isFalse);
    expect(signal.isEnd, isFalse);
    expect(cabSignalingEnd, isNotNull);
    expect(cabSignalingEnd!.isStart, isFalse);
    expect(cabSignalingEnd.isEnd, isTrue);
  });
  test('test cumulativeHeight calculation', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(
        nonStandardTrackEquipmentSegments: [
          _trackEquipmentSegment(.etcsL2ExtSpeedReversingImpossible, 0, 9999),
        ],
      ),
      data: [
        CurvePoint(order: 100, kilometre: []),
        CABSignaling(order: 200, kilometre: [], isStart: true),
        ServicePoint(name: '', abbreviation: '', order: 300, kilometre: []),
        CABSignaling(order: 400, kilometre: []),
        Signal(order: 500, kilometre: []),
      ],
    );

    // WHEN
    final curvePoint = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 0);
    final cabSignalingStart = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 1);
    final servicePoint = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 2);
    final cabSignalingEnd = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 3);
    final signal = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 4);

    // THEN
    var expectedHeight = 0.0;
    expect(curvePoint, isNotNull);
    expect(curvePoint!.cumulativeHeight, expectedHeight);
    expect(cabSignalingStart, isNotNull);
    expect(cabSignalingStart!.cumulativeHeight, expectedHeight += CellRowBuilder.rowHeight);
    expect(servicePoint, isNotNull);
    expect(servicePoint!.cumulativeHeight, expectedHeight += (CellRowBuilder.rowHeight / 2));
    expect(cabSignalingEnd, isNotNull);
    expect(cabSignalingEnd!.cumulativeHeight, expectedHeight += ServicePointRow.baseRowHeight);
    expect(signal, isNotNull);
    expect(signal!.cumulativeHeight, expectedHeight += (CellRowBuilder.rowHeight / 2));
  });
  test('test cumulativeHeight calculation without start', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(
        nonStandardTrackEquipmentSegments: [
          _trackEquipmentSegment(.etcsL1lsSingleTrackNoBlock, null, 9000),
        ],
      ),
      data: [
        CurvePoint(order: 100, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 200, kilometre: []),
        Signal(order: 300, kilometre: []),
      ],
    );

    // WHEN
    final curvePoint = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 0);
    final servicePoint = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 1);
    final signal = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 2);

    // THEN
    var expectedHeight = 0.0;
    expect(curvePoint, isNotNull);
    expect(curvePoint!.cumulativeHeight, expectedHeight);
    expect(servicePoint, isNotNull);
    expect(servicePoint!.cumulativeHeight, expectedHeight += (CellRowBuilder.rowHeight / 2));
    expect(signal, isNotNull);
    expect(signal!.cumulativeHeight, expectedHeight += ServicePointRow.baseRowHeight);
  });
  test('test trackEquipmentType mapping', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(
        nonStandardTrackEquipmentSegments: [
          _trackEquipmentSegment(.etcsL2ExtSpeedReversingPossible, 150, 250),
          _trackEquipmentSegment(.etcsL2ConvSpeedReversingImpossible, 250, 350),
          _trackEquipmentSegment(.etcsL2ExtSpeedReversingImpossible, 350, 450),
          _trackEquipmentSegment(.etcsL1ls2TracksWithSingleTrackEquipment, 450, 550),
          _trackEquipmentSegment(.etcsL1lsSingleTrackNoBlock, 550, 650),
        ],
      ),
      data: [
        CurvePoint(order: 100, kilometre: []),
        CABSignaling(order: 200, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 300, kilometre: []),
        Signal(order: 400, kilometre: []),
        ConnectionTrack(order: 500, kilometre: []),
        LevelCrossing(order: 600, kilometre: []),
      ],
    );

    // WHEN
    final curvePoint = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 0);
    final cabSignaling = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 1);
    final servicePoint = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 2);
    final signal = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 3);
    final connectionTrack = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 4);
    final levelCrossing = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 5);

    // THEN
    expect(curvePoint, isNull);
    expect(cabSignaling, isNotNull);
    expect(cabSignaling!.trackEquipmentType, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
    expect(servicePoint, isNotNull);
    expect(servicePoint!.trackEquipmentType, TrackEquipmentType.etcsL2ConvSpeedReversingImpossible);
    expect(signal, isNotNull);
    expect(signal!.trackEquipmentType, TrackEquipmentType.etcsL2ExtSpeedReversingImpossible);
    expect(connectionTrack, isNotNull);
    expect(connectionTrack!.trackEquipmentType, TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment);
    expect(levelCrossing, isNotNull);
    expect(levelCrossing!.trackEquipmentType, TrackEquipmentType.etcsL1lsSingleTrackNoBlock);
  });

  test('test conventional extended speed border', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(
        nonStandardTrackEquipmentSegments: [
          _trackEquipmentSegment(.etcsL2ExtSpeedReversingPossible, 150, 250),
          _trackEquipmentSegment(.etcsL2ConvSpeedReversingImpossible, 250, 350),
          _trackEquipmentSegment(.etcsL1ls2TracksWithSingleTrackEquipment, 350, 450),
          _trackEquipmentSegment(.etcsL2ConvSpeedReversingImpossible, 450, 550),
          _trackEquipmentSegment(.etcsL2ExtSpeedReversingImpossible, 550, 650),
        ],
      ),
      data: [
        CurvePoint(order: 100, kilometre: []),
        CABSignaling(order: 200, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 300, kilometre: []),
        Signal(order: 400, kilometre: []),
        ConnectionTrack(order: 500, kilometre: []),
        ServicePoint(name: '', abbreviation: '', order: 600, kilometre: []),
      ],
    );

    // WHEN
    final curvePoint = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 0);
    final cabSignaling = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 1);
    final servicePoint = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 2);
    final signal = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 3);
    final connectionTrack = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 4);
    final servicePoint2 = TrackEquipmentRenderData.from(journey.journeyPoints, journey.metadata, 5);

    // THEN
    expect(curvePoint, isNull);
    expect(cabSignaling, isNotNull);
    expect(cabSignaling!.isConventionalExtendedSpeedBorder, isFalse);
    expect(servicePoint, isNotNull);
    expect(servicePoint!.isConventionalExtendedSpeedBorder, isTrue);
    expect(signal, isNotNull);
    expect(signal!.isConventionalExtendedSpeedBorder, isFalse);
    expect(connectionTrack, isNotNull);
    expect(connectionTrack!.isConventionalExtendedSpeedBorder, isFalse);
    expect(servicePoint2, isNotNull);
    expect(servicePoint2!.isConventionalExtendedSpeedBorder, isTrue);
  });
}

NonStandardTrackEquipmentSegment _trackEquipmentSegment(TrackEquipmentType type, int? startOrder, int? endOrder) {
  return NonStandardTrackEquipmentSegment(
    startKm: [],
    endKm: [],
    type: type,
    startOrder: startOrder,
    endOrder: endOrder,
  );
}
