import 'package:das_client/model/journey/track_equipment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Test track equipment', () {
    test('Test track equipment on location with start and end location', () {
      // given
      final trackEquipment = TrackEquipment(
        type: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
        startLocation: 100.0,
        endLocation: 300.0,
        appliesToWholeSp: false,
      );

      // when
      final belowStart = trackEquipment.isOnLocation(50.0);
      final onStart = trackEquipment.isOnLocation(100.0);
      final between = trackEquipment.isOnLocation(200.0);
      final onEnd = trackEquipment.isOnLocation(300.0);
      final aboveEnd = trackEquipment.isOnLocation(400.0);

      // then
      expect(belowStart, isFalse);
      expect(onStart, isTrue);
      expect(between, isTrue);
      expect(onEnd, isTrue);
      expect(aboveEnd, isFalse);
    });

    test('Test track equipment on location that applies whole segment', () async {
      final trackEquipment = TrackEquipment(
        type: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
        appliesToWholeSp: true,
      );

      // this combination would normally not happen but should be tested.
      final trackEquipmentWithStartEnd = TrackEquipment(
        type: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
        startLocation: 100.0,
        endLocation: 300.0,
        appliesToWholeSp: true,
      );

      // when
      final onLocation1 = trackEquipment.isOnLocation(0);
      final onLocation2 = trackEquipment.isOnLocation(9999);
      final belowStart = trackEquipmentWithStartEnd.isOnLocation(50.0);
      final onStart = trackEquipmentWithStartEnd.isOnLocation(100.0);
      final between = trackEquipmentWithStartEnd.isOnLocation(200.0);
      final onEnd = trackEquipmentWithStartEnd.isOnLocation(300.0);
      final aboveEnd = trackEquipmentWithStartEnd.isOnLocation(400.0);

      // then
      expect(onLocation1, isTrue);
      expect(onLocation2, isTrue);
      expect(belowStart, isTrue);
      expect(onStart, isTrue);
      expect(between, isTrue);
      expect(onEnd, isTrue);
      expect(aboveEnd, isTrue);
    });

    test('Test track equipment on location with only start or end location', () async {
      final trackEquipmentWithStart = TrackEquipment(
        type: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
        startLocation: 300.0,
      );

      final trackEquipmentWithEnd = TrackEquipment(
        type: TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
        endLocation: 400.0,
      );

      // when
      final belowStart = trackEquipmentWithStart.isOnLocation(100);
      final onStart = trackEquipmentWithStart.isOnLocation(300);
      final aboveStart = trackEquipmentWithStart.isOnLocation(400);
      final belowEnd = trackEquipmentWithEnd.isOnLocation(100);
      final onEnd = trackEquipmentWithEnd.isOnLocation(400);
      final aboveEnd = trackEquipmentWithEnd.isOnLocation(600);

      // then
      expect(belowStart, isFalse);
      expect(onStart, isTrue);
      expect(aboveStart, isTrue);
      expect(belowEnd, isTrue);
      expect(onEnd, isTrue);
      expect(aboveEnd, isFalse);
    });
  });


  group('Test track equipment type', () {
    test('Test string factory for track equipment type', () {
      // when
      final tracksWithSingleTrackEquipment = TrackEquipmentType.from('ETCS-L1LS-2TracksWithSingleTrackEquipment');
      final convSpeedReversingImpossible = TrackEquipmentType.from('ETCS-L2-convSpeedReversingImpossible');
      final extSpeedReversingPossible = TrackEquipmentType.from('ETCS-L2-extSpeedReversingPossible');
      final extSpeedReversingImpossible = TrackEquipmentType.from('ETCS-L2-extSpeedReversingImpossible');

      // then
      expect(tracksWithSingleTrackEquipment, TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment);
      expect(convSpeedReversingImpossible, TrackEquipmentType.etcsL2ConvSpeedReversingImpossible);
      expect(extSpeedReversingPossible, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
      expect(extSpeedReversingImpossible, TrackEquipmentType.etcsL2ExtSpeedReversingImpossible);
    });
  });
}
