import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/track_equipment_segment.dart';

void main() {
  group('Test track equipment', () {
    test('Test track equipment applies to order', () {
      // given
      final trackEquipment = _etcsL2ExtSpeedReversingPossible(100, 300);

      // when
      final belowStart = trackEquipment.appliesToOrder(50);
      final onStart = trackEquipment.appliesToOrder(100);
      final between = trackEquipment.appliesToOrder(200);
      final onEnd = trackEquipment.appliesToOrder(300);
      final aboveEnd = trackEquipment.appliesToOrder(400);

      // then
      expect(belowStart, isFalse);
      expect(onStart, isTrue);
      expect(between, isTrue);
      expect(onEnd, isTrue);
      expect(aboveEnd, isFalse);
    });
    test('Test track equipment sorting', () {
      // given
      final trackEquipment1 = _etcsL2ExtSpeedReversingPossible(null, 200);
      final trackEquipment2 = _etcsL2ExtSpeedReversingImpossible(300, 500);
      final trackEquipment3 = _etcsL2ConvSpeedReversingImpossible(500, 800);
      final trackEquipment4 = _etcsL2ExtSpeedReversingImpossible(800, 900);
      final trackEquipment5 = _etcsL2ExtSpeedReversingPossible(900, null);
      final trackEquipments = [
        trackEquipment1,
        trackEquipment2,
        trackEquipment3,
        trackEquipment4,
        trackEquipment5,
      ];

      // when
      trackEquipments.shuffle();
      trackEquipments.sort();

      // then
      expect(trackEquipments[0], trackEquipment1);
      expect(trackEquipments[1], trackEquipment2);
      expect(trackEquipments[2], trackEquipment3);
      expect(trackEquipments[3], trackEquipment4);
      expect(trackEquipments[4], trackEquipment5);
    });
  });

  group('Test track equipment CAB signaling', () {
    test('Test CAB signaling start and end for connected segment', () {
      // given
      final trackEquipment1 = _etcsL2ExtSpeedReversingPossible(100, 300);
      final trackEquipment2 = _etcsL2ExtSpeedReversingImpossible(300, 500);
      final trackEquipment3 = _etcsL2ConvSpeedReversingImpossible(500, 800);
      final trackEquipment4 = _etcsL2ExtSpeedReversingImpossible(800, 900);
      final trackEquipment5 = _etcsL2ExtSpeedReversingPossible(900, 1000);

      final trackEquipments = [
        trackEquipment1,
        trackEquipment2,
        trackEquipment3,
        trackEquipment4,
        trackEquipment5,
      ];

      // when
      final withCABSignalingStart = trackEquipments.withCABSignalingStart;
      final withCABSignalingEnd = trackEquipments.withCABSignalingEnd;

      // then
      expect(withCABSignalingStart, hasLength(1));
      expect(withCABSignalingStart.first, trackEquipment1);
      expect(withCABSignalingEnd, hasLength(1));
      expect(withCABSignalingEnd.first, trackEquipment5);
    });

    test('Test CAB signaling start and end for separated segments', () {
      // given
      final trackEquipment1Segment1 = _etcsL2ExtSpeedReversingPossible(200, 300);
      final trackEquipment2Segment1 = _etcsL2ExtSpeedReversingImpossible(300, 600);

      final trackEquipment1Segment2 = _etcsL2ConvSpeedReversingImpossible(800, 1000);
      final trackEquipment2Segment2 = _etcsL2ExtSpeedReversingImpossible(1000, 1200);
      final trackEquipment3Segment2 = _etcsL2ExtSpeedReversingPossible(1200, 1500);

      final trackEquipments = [
        trackEquipment1Segment1,
        trackEquipment2Segment1,
        trackEquipment1Segment2,
        trackEquipment2Segment2,
        trackEquipment3Segment2,
      ];

      // when
      final withCABSignalingStart = trackEquipments.withCABSignalingStart;
      final withCABSignalingEnd = trackEquipments.withCABSignalingEnd;

      // then
      expect(withCABSignalingStart, hasLength(2));
      expect(withCABSignalingStart.elementAt(0), trackEquipment1Segment1);
      expect(withCABSignalingStart.elementAt(1), trackEquipment1Segment2);
      expect(withCABSignalingEnd, hasLength(2));
      expect(withCABSignalingEnd.elementAt(0), trackEquipment2Segment1);
      expect(withCABSignalingEnd.elementAt(1), trackEquipment3Segment2);
    });

    test('Test CAB signaling start and end with single track equipments and a L1LS in between', () {
      // given
      final trackEquipment1 = _etcsL2ExtSpeedReversingPossible(100, 300);
      final trackEquipment2 = _etcsL1ls2TracksWithSingleTrackEquipment(300, 500);
      final trackEquipment3 = _etcsL2ConvSpeedReversingImpossible(500, 800);

      final trackEquipments = [
        trackEquipment1,
        trackEquipment2,
        trackEquipment3,
      ];

      // when
      final withCABSignalingStart = trackEquipments.withCABSignalingStart;
      final withCABSignalingEnd = trackEquipments.withCABSignalingEnd;

      // then
      expect(withCABSignalingStart, hasLength(2));
      expect(withCABSignalingStart.elementAt(0), trackEquipment1);
      expect(withCABSignalingStart.elementAt(1), trackEquipment3);
      expect(withCABSignalingEnd, hasLength(2));
      expect(withCABSignalingEnd.elementAt(0), trackEquipment1);
      expect(withCABSignalingEnd.elementAt(1), trackEquipment3);
    });

    test('Test CAB signaling start and end with single track equipment', () {
      // given
      final trackEquipment1 = _etcsL2ExtSpeedReversingPossible(100, 300);

      final trackEquipments = [trackEquipment1];

      // when
      final withCABSignalingStart = trackEquipments.withCABSignalingStart;
      final withCABSignalingEnd = trackEquipments.withCABSignalingEnd;

      // then
      expect(withCABSignalingStart, hasLength(1));
      expect(withCABSignalingStart.elementAt(0), trackEquipment1);
      expect(withCABSignalingEnd, hasLength(1));
      expect(withCABSignalingEnd.elementAt(0), trackEquipment1);
    });

    test('Test CAB signaling with track equipments that start and end outside train journey', () {
      // given
      final startOutsideJourney = _etcsL2ExtSpeedReversingPossible(null, 100);
      final insideJourney = _etcsL2ExtSpeedReversingPossible(300, 500);
      final endOutsideJourney = _etcsL2ExtSpeedReversingPossible(700, null);

      final trackEquipments = [
        startOutsideJourney,
        insideJourney,
        endOutsideJourney,
      ];

      // when
      final withCABSignalingStart = trackEquipments.withCABSignalingStart;
      final withCABSignalingEnd = trackEquipments.withCABSignalingEnd;

      // then
      expect(withCABSignalingStart, hasLength(2));
      expect(withCABSignalingStart.elementAt(0), insideJourney);
      expect(withCABSignalingStart.elementAt(1), endOutsideJourney);
      expect(withCABSignalingEnd, hasLength(2));
      expect(withCABSignalingEnd.elementAt(0), startOutsideJourney);
      expect(withCABSignalingEnd.elementAt(1), insideJourney);
    });
  });

  group('Test track equipment type', () {
    test('Test if type is ETCS level 2', () {
      // when
      final tracksWithSingleTrackEquipment = TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment.isEtcsL2;
      final convSpeedReversingImpossible = TrackEquipmentType.etcsL2ConvSpeedReversingImpossible.isEtcsL2;
      final extSpeedReversingPossible = TrackEquipmentType.etcsL2ExtSpeedReversingPossible.isEtcsL2;
      final extSpeedReversingImpossible = TrackEquipmentType.etcsL2ConvSpeedReversingImpossible.isEtcsL2;

      // then
      expect(tracksWithSingleTrackEquipment, isFalse);
      expect(convSpeedReversingImpossible, isTrue);
      expect(extSpeedReversingPossible, isTrue);
      expect(extSpeedReversingImpossible, isTrue);
    });
  });
}

NonStandardTrackEquipmentSegment _etcsL2ExtSpeedReversingPossible(int? startOrder, int? endOrder) {
  return NonStandardTrackEquipmentSegment(
    type: .etcsL2ExtSpeedReversingPossible,
    startOrder: startOrder,
    endOrder: endOrder,
    startKm: [],
    endKm: [],
  );
}

NonStandardTrackEquipmentSegment _etcsL2ExtSpeedReversingImpossible(int? startOrder, int? endOrder) {
  return NonStandardTrackEquipmentSegment(
    type: .etcsL2ExtSpeedReversingImpossible,
    startOrder: startOrder,
    endOrder: endOrder,
    startKm: [],
    endKm: [],
  );
}

NonStandardTrackEquipmentSegment _etcsL2ConvSpeedReversingImpossible(int? startOrder, int? endOrder) {
  return NonStandardTrackEquipmentSegment(
    type: .etcsL2ConvSpeedReversingImpossible,
    startOrder: startOrder,
    endOrder: endOrder,
    startKm: [],
    endKm: [],
  );
}

NonStandardTrackEquipmentSegment _etcsL1ls2TracksWithSingleTrackEquipment(int? startOrder, int? endOrder) {
  return NonStandardTrackEquipmentSegment(
    type: .etcsL1ls2TracksWithSingleTrackEquipment,
    startOrder: startOrder,
    endOrder: endOrder,
    startKm: [],
    endKm: [],
  );
}
