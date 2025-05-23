import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/src/model/journey/additional_speed_restriction.dart';
import 'package:sfera/src/model/journey/track_equipment_segment.dart';

main() {
  test('test ASR is displayed outside of ETCS level 2 segments', () {
    // GIVEN
    final asr = AdditionalSpeedRestriction(kmFrom: 5.0, kmTo: 10.0, orderFrom: 500, orderTo: 1000, speed: 50);
    final etcsL1TrackEquipments = [
      _trackEquipment(TrackEquipmentType.etcsL1lsSingleTrackNoBlock, 0, 9999),
    ];

    // WHEN
    final isDisplayedOnETCSL1 = asr.isDisplayed(etcsL1TrackEquipments);
    final isDisplayedWithoutTrackEquipment = asr.isDisplayed([]);

    // THEN
    expect(isDisplayedOnETCSL1, isTrue);
    expect(isDisplayedWithoutTrackEquipment, isTrue);
  });

  test('test ASR is displayed for ETCS level 2 segments below 40km/h', () {
    // GIVEN
    final asrOverWholeSegment = AdditionalSpeedRestriction(
      kmFrom: 0.0,
      kmTo: 15.0,
      orderFrom: 0,
      orderTo: 1500,
      speed: 35,
    );
    final asrStartingOutside = AdditionalSpeedRestriction(
      kmFrom: 0.0,
      kmTo: 7.0,
      orderFrom: 0,
      orderTo: 700,
      speed: 30,
    );
    final asrInside = AdditionalSpeedRestriction(kmFrom: 6.0, kmTo: 8.0, orderFrom: 600, orderTo: 800, speed: 10);
    final asrEndingOutside = AdditionalSpeedRestriction(
      kmFrom: 7.0,
      kmTo: 15.0,
      orderFrom: 700,
      orderTo: 1500,
      speed: 20,
    );
    final etcsL2TrackEquipments = [
      _trackEquipment(TrackEquipmentType.etcsL2ExtSpeedReversingImpossible, 500, 1000),
    ];

    // WHEN
    final isDisplayedAsrOverWholeSegment = asrOverWholeSegment.isDisplayed(etcsL2TrackEquipments);
    final isDisplayedAsrStartingOutside = asrStartingOutside.isDisplayed(etcsL2TrackEquipments);
    final isDisplayedAsrInside = asrInside.isDisplayed(etcsL2TrackEquipments);
    final isDisplayedAsrEndingOutside = asrEndingOutside.isDisplayed(etcsL2TrackEquipments);

    // THEN
    expect(isDisplayedAsrOverWholeSegment, isTrue);
    expect(isDisplayedAsrStartingOutside, isTrue);
    expect(isDisplayedAsrInside, isTrue);
    expect(isDisplayedAsrEndingOutside, isTrue);
  });

  test('test ASR from 40km/h is only not displayed if inside ETCS level 2 segments', () {
    // GIVEN
    final asrOverWholeSegment = AdditionalSpeedRestriction(
      kmFrom: 0.0,
      kmTo: 15.0,
      orderFrom: 0,
      orderTo: 1500,
      speed: 40,
    );
    final asrStartingOutside = AdditionalSpeedRestriction(
      kmFrom: 0.0,
      kmTo: 7.0,
      orderFrom: 0,
      orderTo: 700,
      speed: 40,
    );
    final asrInside = AdditionalSpeedRestriction(kmFrom: 6.0, kmTo: 8.0, orderFrom: 600, orderTo: 800, speed: 40);
    final asrEndingOutside = AdditionalSpeedRestriction(
      kmFrom: 7.0,
      kmTo: 15.0,
      orderFrom: 700,
      orderTo: 1500,
      speed: 40,
    );
    final etcsL2TrackEquipments = [
      _trackEquipment(TrackEquipmentType.etcsL2ConvSpeedReversingImpossible, 500, 1000),
    ];

    // WHEN
    final isDisplayedAsrOverWholeSegment = asrOverWholeSegment.isDisplayed(etcsL2TrackEquipments);
    final isDisplayedAsrStartingOutside = asrStartingOutside.isDisplayed(etcsL2TrackEquipments);
    final isDisplayedAsrInside = asrInside.isDisplayed(etcsL2TrackEquipments);
    final isDisplayedAsrEndingOutside = asrEndingOutside.isDisplayed(etcsL2TrackEquipments);

    // THEN
    expect(isDisplayedAsrOverWholeSegment, isTrue);
    expect(isDisplayedAsrStartingOutside, isTrue);
    expect(isDisplayedAsrInside, isFalse);
    expect(isDisplayedAsrEndingOutside, isTrue);
  });
}

NonStandardTrackEquipmentSegment _trackEquipment(TrackEquipmentType type, int? startOrder, int? endOrder) =>
    NonStandardTrackEquipmentSegment(type: type, startOrder: startOrder, endOrder: endOrder, startKm: [], endKm: []);
