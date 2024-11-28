import 'dart:io';

import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/track_equipment.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/mapper/sfera_model_mapper.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Fimber.plantTree(DebugTree());

  List<File> getFilesForSp(String baseName, int count) {
    final files = <File>[];
    for (var i = 1; i <= count; i++) {
      files.add(File('test_resources/sp/${baseName}_$i.xml'));
    }
    return files;
  }

  Journey getJourney(String trainNumber, int spCount, {String? spTrainNumber}) {
    final journeyFile = File('test_resources/jp/SFERA_JP_$trainNumber.xml');
    final journeyProfile = SferaReplyParser.parse<JourneyProfile>(journeyFile.readAsStringSync());
    expect(journeyProfile.validate(), true);
    final List<SegmentProfile> segmentProfiles = [];

    for (final File file in getFilesForSp('SFERA_SP_${spTrainNumber ?? trainNumber}', spCount)) {
      final segmentProfile = SferaReplyParser.parse<SegmentProfile>(file.readAsStringSync());
      expect(segmentProfile.validate(), true);
      segmentProfiles.add(segmentProfile);
    }

    return SferaModelMapper.mapToJourney(journeyProfile, segmentProfiles);
  }

  test('Test invalid journey on SP missing', () async {
    final journey = getJourney('9999', 4);

    expect(journey.valid, false);
  });

  test('Test service point names are resolved correctly', () async {
    final journey = getJourney('9999', 5);

    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(5));
    expect(servicePoints[0].name.de, 'Bahnhof A');
    expect(servicePoints[1].name.de, 'Haltestelle B');
    expect(servicePoints[2].name.de, 'Halt auf Verlangen C');
    expect(servicePoints[3].name.de, 'Klammerbahnhof D');
    expect(servicePoints[4].name.de, 'Klammerbahnhof D1');
  });

  test('Test journey data types correctly generated', () async {
    final journey = getJourney('9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(16));

    // segment 1
    expect(journey.data[0], TypeMatcher<ServicePoint>());
    expect(journey.data[1], TypeMatcher<Signal>());
    expect(journey.data[2], TypeMatcher<CurvePoint>());
    expect(journey.data[3], TypeMatcher<Signal>());
    // segment 2
    expect(journey.data[4], TypeMatcher<Signal>());
    expect(journey.data[5], TypeMatcher<ServicePoint>());
    expect(journey.data[6], TypeMatcher<Signal>());
    expect(journey.data[7], TypeMatcher<CurvePoint>());
    // segment 3
    expect(journey.data[8], TypeMatcher<CurvePoint>());
    expect(journey.data[9], TypeMatcher<ServicePoint>());
    expect(journey.data[10], TypeMatcher<CurvePoint>());
    expect(journey.data[11], TypeMatcher<Signal>());
    // segment 4
    expect(journey.data[12], TypeMatcher<ServicePoint>());
    expect(journey.data[13], TypeMatcher<Signal>());
    // segment 5
    expect(journey.data[14], TypeMatcher<Signal>());
    expect(journey.data[15], TypeMatcher<ServicePoint>());
  });

  test('Test kilometre are parsed correctly', () async {
    final journey = getJourney('9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(16));

    // segment 1
    expect(journey.data[0].kilometre[0], 0.2);
    expect(journey.data[1].kilometre[0], 0.5);
    expect(journey.data[2].kilometre[0], 0.6);
    expect(journey.data[3].kilometre[0], 0.7);
    // segment 2
    expect(journey.data[4].kilometre[0], 1.2);
    expect(journey.data[5].kilometre[0], 1.5);
    expect(journey.data[6].kilometre[0], 1.7);
    expect(journey.data[7].kilometre[0], 1.8);
    // segment 3
    expect(journey.data[8].kilometre[0], 2.1);
    expect(journey.data[9].kilometre[0], 2.4);
    expect(journey.data[10].kilometre[0], 2.5);
    expect(journey.data[11].kilometre[0], 2.6);
    // segment 4
    expect(journey.data[12].kilometre[0], 3.7);
    expect(journey.data[12].kilometre[1], 0);
    expect(journey.data[13].kilometre[0], 0.2);
    // segment 5
    expect(journey.data[14].kilometre[0], 0.4);
    expect(journey.data[15].kilometre[0], 0.6);
  });

  test('Test order is generated correctly', () async {
    final journey = getJourney('9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(16));

    // segment 1
    expect(journey.data[0].order, 000200);
    expect(journey.data[1].order, 000500);
    expect(journey.data[2].order, 000600);
    expect(journey.data[3].order, 000700);
    // segment 2
    expect(journey.data[4].order, 100200);
    expect(journey.data[5].order, 100500);
    expect(journey.data[6].order, 100700);
    expect(journey.data[7].order, 100800);
    // segment 3
    expect(journey.data[8].order, 200100);
    expect(journey.data[9].order, 200400);
    expect(journey.data[10].order, 200500);
    expect(journey.data[11].order, 200600);
    // segment 4
    expect(journey.data[12].order, 300700);
    expect(journey.data[13].order, 300900);
    // segment 5
    expect(journey.data[14].order, 400100);
    expect(journey.data[15].order, 400300);
  });

  test('Test track equipment is generated correctly', () async {
    final journey = getJourney('9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(16));

    // segment 1
    expect(journey.data[0].trackEquipment, isEmpty);
    expect(journey.data[1].trackEquipment, isEmpty);
    expect(journey.data[2].trackEquipment, isEmpty);
    expect(journey.data[3].trackEquipment, isEmpty);
    // segment 2
    expect(journey.data[4].trackEquipment, hasLength(1));
    expect(journey.data[4].trackEquipment[0].appliesToWholeSp, isTrue);
    expect(journey.data[4].trackEquipment[0].type, TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment);
    expect(journey.data[5].trackEquipment, hasLength(1));
    expect(journey.data[5].trackEquipment[0].type, TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment);
    expect(journey.data[6].trackEquipment, hasLength(1));
    expect(journey.data[6].trackEquipment[0].type, TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment);
    expect(journey.data[7].trackEquipment, hasLength(1));
    expect(journey.data[7].trackEquipment[0].type, TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment);
    // segment 3
    expect(journey.data[8].trackEquipment, hasLength(1));
    expect(journey.data[8].trackEquipment[0].appliesToWholeSp, isFalse);
    expect(journey.data[8].trackEquipment[0].startLocation, 100.0);
    expect(journey.data[8].trackEquipment[0].endLocation, 400.0);
    expect(journey.data[8].trackEquipment[0].type, TrackEquipmentType.etcsL2ConvSpeedReversingImpossible);
    expect(journey.data[9].trackEquipment, hasLength(1));
    expect(journey.data[9].trackEquipment[0].type, TrackEquipmentType.etcsL2ConvSpeedReversingImpossible);
    expect(journey.data[10].trackEquipment, hasLength(1));
    expect(journey.data[10].trackEquipment[0].type, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
    expect(journey.data[10].trackEquipment[0].appliesToWholeSp, isFalse);
    expect(journey.data[10].trackEquipment[0].startLocation, 500.0);
    expect(journey.data[10].trackEquipment[0].endLocation, isNull);
    expect(journey.data[11].trackEquipment, hasLength(1));
    expect(journey.data[11].trackEquipment[0].type, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
    // segment 4
    expect(journey.data[12].trackEquipment, hasLength(1));
    expect(journey.data[12].trackEquipment[0].type, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
    expect(journey.data[12].trackEquipment[0].appliesToWholeSp, isFalse);
    expect(journey.data[12].trackEquipment[0].startLocation, isNull);
    expect(journey.data[12].trackEquipment[0].endLocation, 800.0);
    expect(journey.data[13].trackEquipment, isEmpty);
    // segment 5
    expect(journey.data[14].trackEquipment, isEmpty);
    expect(journey.data[15].trackEquipment, hasLength(1));
    expect(journey.data[15].trackEquipment[0].startLocation, 300.0);
    expect(journey.data[15].trackEquipment[0].endLocation, 800.0);
    expect(journey.data[15].trackEquipment[0].type, TrackEquipmentType.etcsL2ExtSpeedReversingImpossible);
    expect(journey.data[15].trackEquipment[0].appliesToWholeSp, isFalse);
  });

  test('Test signals are generated correctly', () async {
    final journey = getJourney('9999', 5);
    final signals = journey.data.where((it) => it.type == Datatype.signal).cast<Signal>().toList();

    expect(journey.valid, true);
    expect(signals, hasLength(7));
    expect(signals[0].visualIdentifier, 'B1');
    expect(signals[0].functions, hasLength(1));
    expect(signals[0].functions[0], SignalFunction.block);
    expect(signals[1].visualIdentifier, 'S1');
    expect(signals[1].functions, hasLength(2));
    expect(signals[1].functions[0], SignalFunction.block);
    expect(signals[1].functions[1], SignalFunction.laneChange);
    expect(signals[2].visualIdentifier, 'E1');
    expect(signals[2].functions, hasLength(1));
    expect(signals[2].functions[0], SignalFunction.entry);
    expect(signals[3].visualIdentifier, 'A1');
    expect(signals[3].functions, hasLength(1));
    expect(signals[3].functions[0], SignalFunction.exit);
    expect(signals[4].visualIdentifier, 'AB1');
    expect(signals[4].functions, hasLength(1));
    expect(signals[4].functions[0], SignalFunction.intermediate);
    expect(signals[5].visualIdentifier, 'D1');
    expect(signals[5].functions, hasLength(1));
    expect(signals[5].functions[0], SignalFunction.protection);
    expect(signals[6].visualIdentifier, 'BAB1');
    expect(signals[6].functions, hasLength(2));
    expect(signals[6].functions[0], SignalFunction.block);
    expect(signals[6].functions[1], SignalFunction.intermediate);
  });

  test('Test curvePoint are generated correctly', () async {
    final journey = getJourney('9999', 5);
    final curvePoints = journey.data.where((it) => it.type == Datatype.curvePoint).cast<CurvePoint>().toList();

    expect(journey.valid, true);
    expect(curvePoints, hasLength(4));
    expect(curvePoints.where((c) => c.curvePointType == CurvePointType.end), isEmpty);
    expect(curvePoints[0].curvePointType, CurvePointType.begin);
    expect(curvePoints[0].curveType, CurveType.curve);
    expect(curvePoints[0].comment, 'Kurve 1');
    expect(curvePoints[1].curvePointType, CurvePointType.begin);
    expect(curvePoints[1].curveType, CurveType.curve);
    expect(curvePoints[1].comment, 'Kurve 1');
    expect(curvePoints[2].curvePointType, CurvePointType.begin);
    expect(curvePoints[2].curveType, CurveType.stationExitCurve);
    expect(curvePoints[2].comment, 'Kurve 2');
    expect(curvePoints[3].curvePointType, CurvePointType.begin);
    expect(curvePoints[3].curveType, CurveType.curveAfterHalt);
    expect(curvePoints[3].comment, 'Kurve 3');
  });

  test('Test stop on demand is parsed correctly', () async {
    final journey = getJourney('9999', 5);
    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(5));
    expect(servicePoints[0].mandatoryStop, true);
    expect(servicePoints[1].mandatoryStop, true);
    expect(servicePoints[2].mandatoryStop, false);
    expect(servicePoints[3].mandatoryStop, true);
    expect(servicePoints[4].mandatoryStop, true);
  });

  test('Test passing point is parsed correctly', () async {
    final journey = getJourney('9999', 5);
    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(5));
    expect(servicePoints[0].isStop, true);
    expect(servicePoints[1].isStop, false);
    expect(servicePoints[2].isStop, true);
    expect(servicePoints[3].isStop, true);
    expect(servicePoints[4].isStop, true);
  });

  test('Test station point is parsed correctly', () async {
    final journey = getJourney('9999', 5);
    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(5));
    expect(servicePoints[0].isStation, true);
    expect(servicePoints[1].isStation, true);
    expect(servicePoints[2].isStation, false);
    expect(servicePoints[3].isStation, true);
    expect(servicePoints[4].isStation, true);
  });

  test('Test bracket stations is parsed correctly', () async {
    final journey = getJourney('9999', 5);
    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(5));
    expect(servicePoints[0].bracketStation, isNull);
    expect(servicePoints[1].bracketStation, isNull);
    expect(servicePoints[2].bracketStation, isNull);
    expect(servicePoints[3].bracketStation, isNotNull);
    expect(servicePoints[3].bracketStation!.mainStationAbbreviation, isNull);
    expect(servicePoints[4].bracketStation, isNotNull);
    expect(servicePoints[4].bracketStation!.mainStationAbbreviation, 'D');
  });

  test('Test protection section is parsed correctly', () async {
    final journey = getJourney('513', 1);
    final protectionSections = journey.data.where((it) => it.type == Datatype.protectionSection).cast<ProtectionSection>().toList();

    expect(journey.valid, true);
    expect(protectionSections, hasLength(6));
    expect(protectionSections[0].isLong, true);
    expect(protectionSections[0].isOptional, true);
    expect(protectionSections[1].isLong, true);
    expect(protectionSections[1].isOptional, false);
    expect(protectionSections[2].isLong, true);
    expect(protectionSections[2].isOptional, true);
    expect(protectionSections[3].isLong, true);
    expect(protectionSections[3].isOptional, true);
    expect(protectionSections[4].isLong, false);
    expect(protectionSections[4].isOptional, true);
    expect(protectionSections[5].isLong, false);
    expect(protectionSections[5].isOptional, false);
  });

  test('Test additional speed restriction is parsed correctly no items between', () async {
    final journey = getJourney('513', 1);
    final speedRestrictions = journey.data.where((it) => it.type == Datatype.additionalSpeedRestriction).cast<AdditionalSpeedRestrictionData>().toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(1));
    expect(speedRestrictions[0].restriction.kmFrom, 64.2);
    expect(speedRestrictions[0].restriction.kmTo, 63.2);
    expect(speedRestrictions[0].restriction.orderFrom, 700);
    expect(speedRestrictions[0].restriction.orderTo, 800);
    expect(speedRestrictions[0].restriction.speed, 60);

    expect(journey.metadata.additionalSpeedRestrictions, hasLength(1));
    expect(journey.metadata.additionalSpeedRestrictions[0].kmFrom, 64.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].kmTo, 63.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderFrom, 700);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderTo, 800);
    expect(journey.metadata.additionalSpeedRestrictions[0].speed, 60);
  });

  test('Test additional speed restriction is parsed correctly over multiple segments', () async {
    final journey = getJourney('500', 3);
    final speedRestrictions = journey.data.where((it) => it.type == Datatype.additionalSpeedRestriction).cast<AdditionalSpeedRestrictionData>().toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(2));
    expect(speedRestrictions[0].restriction.kmFrom, 64.2);
    expect(speedRestrictions[0].restriction.kmTo, 47.2);
    expect(speedRestrictions[0].restriction.orderFrom, 700);
    expect(speedRestrictions[0].restriction.orderTo, 206800);
    expect(speedRestrictions[0].restriction.speed, 60);
    expect(speedRestrictions[0].order, 700);
    expect(speedRestrictions[1].restriction.kmFrom, 64.2);
    expect(speedRestrictions[1].restriction.kmTo, 47.2);
    expect(speedRestrictions[1].restriction.orderFrom, 700);
    expect(speedRestrictions[1].restriction.orderTo, 206800);
    expect(speedRestrictions[1].restriction.speed, 60);
    expect(speedRestrictions[1].order, 206800);

    expect(journey.metadata.additionalSpeedRestrictions, hasLength(1));
    expect(journey.metadata.additionalSpeedRestrictions[0].kmFrom, 64.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].kmTo, 47.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderFrom, 700);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderTo, 206800);
    expect(journey.metadata.additionalSpeedRestrictions[0].speed, 60);
  });

  test('Test additional speed restriction without a date', () async {
    final journey = getJourney('513_asp_no_date', 1, spTrainNumber: '513');
    final speedRestrictions = journey.data.where((it) => it.type == Datatype.additionalSpeedRestriction).cast<AdditionalSpeedRestrictionData>().toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(1));
    expect(speedRestrictions[0].restriction.kmFrom, 64.2);
    expect(speedRestrictions[0].restriction.kmTo, 63.2);
    expect(speedRestrictions[0].restriction.orderFrom, 700);
    expect(speedRestrictions[0].restriction.orderTo, 800);
    expect(speedRestrictions[0].restriction.speed, 60);

    expect(journey.metadata.additionalSpeedRestrictions, hasLength(1));
    expect(journey.metadata.additionalSpeedRestrictions[0].kmFrom, 64.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].kmTo, 63.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderFrom, 700);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderTo, 800);
    expect(journey.metadata.additionalSpeedRestrictions[0].speed, 60);
  });

  test('Test additional speed restriction with date in the past', () async {
    final journey = getJourney('513_asp_date_before', 1, spTrainNumber: '513');
    final speedRestrictions = journey.data.where((it) => it.type == Datatype.additionalSpeedRestriction).cast<AdditionalSpeedRestrictionData>().toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(0));
    expect(journey.metadata.additionalSpeedRestrictions, hasLength(0));
  });

  test('Test additional speed restriction with date in the future', () async {
    final journey = getJourney('513_asp_date_after', 1, spTrainNumber: '513');
    final speedRestrictions = journey.data.where((it) => it.type == Datatype.additionalSpeedRestriction).cast<AdditionalSpeedRestrictionData>().toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(0));
    expect(journey.metadata.additionalSpeedRestrictions, hasLength(0));
  });
}
