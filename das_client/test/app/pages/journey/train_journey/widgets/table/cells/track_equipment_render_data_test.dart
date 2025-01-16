import 'package:das_client/app/pages/journey/train_journey/widgets/table/base_row_builder.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/render_data/track_equipment_render_data.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/connection_track.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/track_equipment_segment.dart';
import 'package:das_client/model/localized_string.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('test CAB signaling start and end', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(
        nonStandardTrackEquipmentSegments: [
          _trackEquipmentSegment(TrackEquipmentType.etcsL2ExtSpeedReversingImpossible, 0, 9999),
        ],
      ),
      data: [
        CABSignaling(order: 100, kilometre: [], isStart: true),
        Signal(order: 200, kilometre: []),
        CABSignaling(order: 300, kilometre: [], isStart: false),
      ],
    );

    // WHEN
    final cabSignalingStart = TrackEquipmentRenderData.from(journey.data, journey.metadata, 0);
    final signal = TrackEquipmentRenderData.from(journey.data, journey.metadata, 1);
    final cabSignalingEnd = TrackEquipmentRenderData.from(journey.data, journey.metadata, 2);

    // THEN
    expect(cabSignalingStart.isCABStart, isTrue);
    expect(cabSignalingStart.isCABEnd, isFalse);
    expect(signal.isCABStart, isFalse);
    expect(signal.isCABEnd, isFalse);
    expect(cabSignalingEnd.isCABStart, isFalse);
    expect(cabSignalingEnd.isCABEnd, isTrue);
  });
  test('test cumulativeHeight calculation', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(
        nonStandardTrackEquipmentSegments: [
          _trackEquipmentSegment(TrackEquipmentType.etcsL2ExtSpeedReversingImpossible, 0, 9999),
        ],
      ),
      data: [
        CurvePoint(order: 100, kilometre: []),
        CABSignaling(order: 200, kilometre: [], isStart: true),
        ServicePoint(name: LocalizedString(), order: 300, kilometre: []),
        CABSignaling(order: 400, kilometre: []),
        Signal(order: 500, kilometre: []),
      ],
    );

    // WHEN
    final curvePoint = TrackEquipmentRenderData.from(journey.data, journey.metadata, 0);
    final cabSignalingStart = TrackEquipmentRenderData.from(journey.data, journey.metadata, 1);
    final servicePoint = TrackEquipmentRenderData.from(journey.data, journey.metadata, 2);
    final cabSignalingEnd = TrackEquipmentRenderData.from(journey.data, journey.metadata, 3);
    final signal = TrackEquipmentRenderData.from(journey.data, journey.metadata, 4);

    // THEN
    var expectedHeight = 0.0;
    expect(curvePoint.cumulativeHeight, expectedHeight);
    expect(cabSignalingStart.cumulativeHeight, expectedHeight += BaseRowBuilder.rowHeight);
    expect(servicePoint.cumulativeHeight, expectedHeight += (BaseRowBuilder.rowHeight / 2));
    expect(cabSignalingEnd.cumulativeHeight, expectedHeight += ServicePointRow.rowHeight);
    expect(signal.cumulativeHeight, expectedHeight += BaseRowBuilder.rowHeight);
  });
  test('test trackEquipmentType mapping', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(nonStandardTrackEquipmentSegments: [
        _trackEquipmentSegment(TrackEquipmentType.etcsL2ExtSpeedReversingPossible, 150, 250),
        _trackEquipmentSegment(TrackEquipmentType.etcsL2ConvSpeedReversingImpossible, 250, 350),
        _trackEquipmentSegment(TrackEquipmentType.etcsL2ExtSpeedReversingImpossible, 350, 450),
        _trackEquipmentSegment(TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment, 450, 550),
      ]),
      data: [
        CurvePoint(order: 100, kilometre: []),
        CABSignaling(order: 200, kilometre: []),
        ServicePoint(name: LocalizedString(), order: 300, kilometre: []),
        Signal(order: 400, kilometre: []),
        ConnectionTrack(order: 500, kilometre: []),
      ],
    );

    // WHEN
    final curvePoint = TrackEquipmentRenderData.from(journey.data, journey.metadata, 0);
    final cabSignaling = TrackEquipmentRenderData.from(journey.data, journey.metadata, 1);
    final servicePoint = TrackEquipmentRenderData.from(journey.data, journey.metadata, 2);
    final signal = TrackEquipmentRenderData.from(journey.data, journey.metadata, 3);
    final connectionTrack = TrackEquipmentRenderData.from(journey.data, journey.metadata, 4);

    // THEN
    expect(curvePoint.trackEquipmentType, isNull);
    expect(cabSignaling.trackEquipmentType, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
    expect(servicePoint.trackEquipmentType, TrackEquipmentType.etcsL2ConvSpeedReversingImpossible);
    expect(signal.trackEquipmentType, TrackEquipmentType.etcsL2ExtSpeedReversingImpossible);
    expect(connectionTrack.trackEquipmentType, isNull); // non ETCS level 2 are ignored
  });

  test('test conventional extended speed border', () {
    // GIVEN
    final journey = Journey(
      metadata: Metadata(nonStandardTrackEquipmentSegments: [
        _trackEquipmentSegment(TrackEquipmentType.etcsL2ExtSpeedReversingPossible, 150, 250),
        _trackEquipmentSegment(TrackEquipmentType.etcsL2ConvSpeedReversingImpossible, 250, 350),
        _trackEquipmentSegment(TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment, 350, 450),
        _trackEquipmentSegment(TrackEquipmentType.etcsL2ConvSpeedReversingImpossible, 450, 550),
        _trackEquipmentSegment(TrackEquipmentType.etcsL2ExtSpeedReversingImpossible, 550, 650),
      ]),
      data: [
        CurvePoint(order: 100, kilometre: []),
        CABSignaling(order: 200, kilometre: []),
        ServicePoint(name: LocalizedString(), order: 300, kilometre: []),
        Signal(order: 400, kilometre: []),
        ConnectionTrack(order: 500, kilometre: []),
        ServicePoint(name: LocalizedString(), order: 600, kilometre: []),
      ],
    );

    // WHEN
    final curvePoint = TrackEquipmentRenderData.from(journey.data, journey.metadata, 0);
    final cabSignaling = TrackEquipmentRenderData.from(journey.data, journey.metadata, 1);
    final servicePoint = TrackEquipmentRenderData.from(journey.data, journey.metadata, 2);
    final signal = TrackEquipmentRenderData.from(journey.data, journey.metadata, 3);
    final connectionTrack = TrackEquipmentRenderData.from(journey.data, journey.metadata, 4);
    final servicePoint2 = TrackEquipmentRenderData.from(journey.data, journey.metadata, 5);

    // THEN
    expect(curvePoint.isConventionalExtendedSpeedBorder, isFalse);
    expect(cabSignaling.isConventionalExtendedSpeedBorder, isFalse);
    expect(servicePoint.isConventionalExtendedSpeedBorder, isTrue);
    expect(signal.isConventionalExtendedSpeedBorder, isFalse);
    expect(connectionTrack.isConventionalExtendedSpeedBorder, isFalse);
    expect(servicePoint2.isConventionalExtendedSpeedBorder, isTrue);
  });
}

NonStandardTrackEquipmentSegment _trackEquipmentSegment(TrackEquipmentType type, int startOrder, int endOrder) {
  return NonStandardTrackEquipmentSegment(
    startKm: [],
    endKm: [],
    type: type,
    startOrder: startOrder,
    endOrder: endOrder,
  );
}
