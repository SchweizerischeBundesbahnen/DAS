import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/delay_dto.dart';
import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';
import 'package:sfera/src/model/journey/foot_note.dart';

void main() {
  Fimber.plantTree(DebugTree());

  List<File> getFilesForSp(String path, String baseName, int count) {
    final files = <File>[];
    for (var i = 1; i <= count; i++) {
      files.add(File('$path/${baseName}_$i.xml'));
    }
    return files;
  }

  List<File> getFilesForTc(String path, String baseName, int count) {
    final files = <File>[];
    for (var i = 1; i <= count; i++) {
      files.add(File('$path/${baseName}_$i.xml'));
    }
    return files;
  }

  Journey getJourney(
    String trainNumber,
    int spCount, {
    String? spPostfix,
    String? jpPostfix,
    String? tcPostfix,
    int tcCount = 0,
    int? relatedTrainInfoEventId,
    Journey? lastJourney,
  }) {
    final resourceDir = Directory('test_resources');
    expect(resourceDir.existsSync(), true);

    // Filter files that match the regex
    final directoryRegex = RegExp('${trainNumber}_.+');
    final testDirectory = resourceDir.listSync().firstWhereOrNull((entry) {
      final baseName = entry.path.split(Platform.pathSeparator).last;
      return entry is Directory && directoryRegex.hasMatch(baseName);
    });
    expect(testDirectory, isNotNull);

    final baseJPFileName = 'SFERA_JP_$trainNumber${jpPostfix != null ? '_$jpPostfix' : ''}';
    final journeyFile = File('${testDirectory!.path}/$baseJPFileName.xml');
    final journeyProfile = SferaReplyParser.parse<JourneyProfileDto>(journeyFile.readAsStringSync());
    expect(journeyProfile.validate(), true);

    final List<SegmentProfileDto> segmentProfiles = [];
    final baseSPFileName = 'SFERA_SP_$trainNumber${spPostfix != null ? '_$spPostfix' : ''}';
    for (final File file in getFilesForSp(testDirectory.path, baseSPFileName, spCount)) {
      final segmentProfile = SferaReplyParser.parse<SegmentProfileDto>(file.readAsStringSync());
      expect(segmentProfile.validate(), true);
      segmentProfiles.add(segmentProfile);
    }

    final List<TrainCharacteristicsDto> trainCharacteristics = [];
    final baseTCFileName = 'SFERA_TC_$trainNumber${tcPostfix != null ? '_$tcPostfix' : ''}';
    for (final File file in getFilesForTc(testDirectory.path, baseTCFileName, tcCount)) {
      final trainCharacteristic = SferaReplyParser.parse<TrainCharacteristicsDto>(file.readAsStringSync());
      expect(trainCharacteristic.validate(), true);
      trainCharacteristics.add(trainCharacteristic);
    }

    RelatedTrainInformationDto? relatedTrainInformation;
    if (relatedTrainInfoEventId != null) {
      final file = File('${testDirectory.path}/SFERA_Event_${trainNumber}_$relatedTrainInfoEventId.xml');
      final g2bEventPayload = SferaReplyParser.parse<G2bEventPayloadDto>(file.readAsStringSync());
      relatedTrainInformation = g2bEventPayload.relatedTrainInformation;
    }

    return SferaModelMapper.mapToJourney(
        journeyProfile: journeyProfile,
        segmentProfiles: segmentProfiles,
        trainCharacteristics: trainCharacteristics,
        relatedTrainInformation: relatedTrainInformation,
        lastJourney: lastJourney);
  }

  test('Test invalid journey on SP missing', () async {
    final journey = getJourney('T9999', 4);

    expect(journey.valid, false);
  });

  test('Test service point names are resolved correctly', () async {
    final journey = getJourney('T9999', 5);

    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(6));
    expect(servicePoints[0].name, 'Bahnhof A');
    expect(servicePoints[1].name, 'Haltestelle B');
    expect(servicePoints[2].name, 'Halt auf Verlangen C');
    expect(servicePoints[3].name, 'Klammerbahnhof D');
    expect(servicePoints[4].name, 'Klammerbahnhof D1');
    expect(servicePoints[5].name, 'Bahnhof E');
  });

  test('Test journey data types correctly generated', () async {
    final journey = getJourney('T9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(24));

    // segment 1
    expect(journey.data[0], TypeMatcher<ServicePoint>());
    expect(journey.data[1], TypeMatcher<Signal>());
    expect(journey.data[2], TypeMatcher<CurvePoint>());
    expect(journey.data[3], TypeMatcher<Signal>());
    expect(journey.data[4], TypeMatcher<ConnectionTrack>());
    // segment 2
    expect(journey.data[5], TypeMatcher<CABSignaling>());
    expect(journey.data[6], TypeMatcher<Signal>());
    expect(journey.data[7], TypeMatcher<ServicePoint>());
    expect(journey.data[8], TypeMatcher<Signal>());
    expect(journey.data[9], TypeMatcher<CurvePoint>());
    expect(journey.data[10], TypeMatcher<ConnectionTrack>());
    // segment 3
    expect(journey.data[11], TypeMatcher<CurvePoint>());
    expect(journey.data[12], TypeMatcher<ConnectionTrack>());
    expect(journey.data[13], TypeMatcher<ServicePoint>());
    expect(journey.data[14], TypeMatcher<CurvePoint>());
    expect(journey.data[15], TypeMatcher<Signal>());
    // segment 4
    expect(journey.data[16], TypeMatcher<SpeedChange>());
    expect(journey.data[17], TypeMatcher<CABSignaling>());
    expect(journey.data[18], TypeMatcher<ServicePoint>());
    expect(journey.data[19], TypeMatcher<SpeedChange>());
    expect(journey.data[20], TypeMatcher<Signal>());
    // segment 5
    expect(journey.data[21], TypeMatcher<ServicePoint>());
    expect(journey.data[22], TypeMatcher<Signal>());
    expect(journey.data[23], TypeMatcher<ServicePoint>());
  });

  test('Test kilometre are parsed correctly', () async {
    final journey = getJourney('T9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(24));

    // segment 1
    expect(journey.data[0].kilometre[0], 0.2);
    expect(journey.data[1].kilometre[0], 0.5);
    expect(journey.data[2].kilometre[0], 0.6);
    expect(journey.data[3].kilometre[0], 0.7);
    expect(journey.data[4].kilometre[0], 0.8);
    // segment 2
    expect(journey.data[5].kilometre[0], 1.2);
    expect(journey.data[6].kilometre[0], 1.2);
    expect(journey.data[7].kilometre[0], 1.5);
    expect(journey.data[8].kilometre[0], 1.7);
    expect(journey.data[9].kilometre[0], 1.8);
    expect(journey.data[10].kilometre[0], 1.9);
    // segment 3
    expect(journey.data[11].kilometre[0], 2.1);
    expect(journey.data[12].kilometre[0], 2.2);
    expect(journey.data[13].kilometre[0], 2.4);
    expect(journey.data[14].kilometre[0], 2.5);
    expect(journey.data[15].kilometre[0], 2.6);
    // segment 4
    expect(journey.data[16].kilometre[0], 3.5);
    expect(journey.data[17].kilometre[0], 3.6);
    expect(journey.data[18].kilometre[0], 3.7);
    expect(journey.data[18].kilometre[1], 0);
    expect(journey.data[19].kilometre[0], 0.1);
    expect(journey.data[20].kilometre[0], 0.2);
    // segment 5
    expect(journey.data[21].kilometre[0], 0.6);
    expect(journey.data[22].kilometre[0], 0.9);
    expect(journey.data[23].kilometre[0], 1.1);
  });

  test('Test order is generated correctly', () async {
    final journey = getJourney('T9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(24));

    // segment 1
    expect(journey.data[0].order, 000200);
    expect(journey.data[1].order, 000500);
    expect(journey.data[2].order, 000600);
    expect(journey.data[3].order, 000700);
    expect(journey.data[4].order, 000800);
    // segment 2
    expect(journey.data[5].order, 100200);
    expect(journey.data[6].order, 100200);
    expect(journey.data[7].order, 100500);
    expect(journey.data[8].order, 100700);
    expect(journey.data[9].order, 100800);
    expect(journey.data[10].order, 100900);
    // segment 3
    expect(journey.data[11].order, 200100);
    expect(journey.data[12].order, 200200);
    expect(journey.data[13].order, 200400);
    expect(journey.data[14].order, 200500);
    expect(journey.data[15].order, 200600);
    // segment 4
    expect(journey.data[16].order, 300500);
    expect(journey.data[17].order, 300600);
    expect(journey.data[18].order, 300700);
    expect(journey.data[19].order, 300800);
    expect(journey.data[20].order, 300900);
    // segment 5
    expect(journey.data[21].order, 400300);
    expect(journey.data[22].order, 400600);
    expect(journey.data[23].order, 400800);
  });

  test('Test track equipment is generated correctly', () async {
    final journey = getJourney('T1', 5);

    expect(journey.valid, true);
    expect(journey.metadata.nonStandardTrackEquipmentSegments, hasLength(7));

    expect(
        journey.metadata.nonStandardTrackEquipmentSegments[0].type, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[0].startOrder, isNull);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[0].endOrder, 1600);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[1].type,
        TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[1].startOrder, 1700);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[1].endOrder, 2300);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[2].type,
        TrackEquipmentType.etcsL2ConvSpeedReversingImpossible);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[2].startOrder, 102500);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[2].endOrder, 103700);
    expect(
        journey.metadata.nonStandardTrackEquipmentSegments[3].type, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[3].startOrder, 103700);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[3].endOrder, 307000);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[4].type,
        TrackEquipmentType.etcsL2ConvSpeedReversingImpossible);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[4].startOrder, 307000);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[4].endOrder, 307800);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[5].type,
        TrackEquipmentType.etcsL2ExtSpeedReversingImpossible);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[5].startOrder, 409200);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[5].endOrder, 410200);
    expect(
        journey.metadata.nonStandardTrackEquipmentSegments[6].type, TrackEquipmentType.etcsL2ExtSpeedReversingPossible);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[6].startOrder, 410200);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[6].endOrder, isNull);
  });

  test('Test speed change on CAB signaling end is generated correctly', () async {
    final journey = getJourney('T1', 5);

    expect(journey.valid, true);

    final cabSignaling = journey.data.where((it) => it.type == Datatype.cabSignaling).cast<CABSignaling>();
    final endSignaling = cabSignaling.where((signaling) => signaling.isEnd).toList();

    expect(endSignaling, hasLength(2));
    expect(endSignaling[0].speedData, isNotNull);
    expect(endSignaling[0].speedData!.speeds[0].trainSeries, TrainSeries.R);
    expect(endSignaling[0].speedData!.speeds[0].incomingSpeeds[0].speed, 55);
    expect(endSignaling[0].speedData!.speeds[0].breakSeries, 115);
    expect(endSignaling[1].speedData, isNotNull);
    expect(endSignaling[1].speedData!.speeds[0].trainSeries, TrainSeries.R);
    expect(endSignaling[1].speedData!.speeds[0].incomingSpeeds[0].speed, 80);
    expect(endSignaling[1].speedData!.speeds[0].breakSeries, 115);
  });

  test('Test single track without block is generated correctly', () async {
    final journey = getJourney('T10', 1);

    expect(journey.valid, true);
    expect(journey.metadata.nonStandardTrackEquipmentSegments, hasLength(1));

    expect(journey.metadata.nonStandardTrackEquipmentSegments[0].type, TrackEquipmentType.etcsL1lsSingleTrackNoBlock);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[0].startOrder, 0);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[0].endOrder, 5000);
  });

  test('Test signals are generated correctly', () async {
    final journey = getJourney('T9999', 5);
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
    final journey = getJourney('T9999', 5);
    final curvePoints = journey.data.where((it) => it.type == Datatype.curvePoint).cast<CurvePoint>().toList();

    expect(journey.valid, true);
    expect(curvePoints, hasLength(4));
    expect(curvePoints.where((c) => c.curvePointType == CurvePointType.end), isEmpty);
    expect(curvePoints[0].curvePointType, CurvePointType.begin);
    expect(curvePoints[0].curveType, CurveType.curve);
    expect(curvePoints[0].comment, 'Kurve 1 comment');
    expect(curvePoints[1].curvePointType, CurvePointType.begin);
    expect(curvePoints[1].curveType, CurveType.curve);
    expect(curvePoints[1].comment, 'Kurve 1 after comment');
    expect(curvePoints[2].curvePointType, CurvePointType.begin);
    expect(curvePoints[2].curveType, CurveType.stationExitCurve);
    expect(curvePoints[2].comment, 'Kurve 5 after stop');
    expect(curvePoints[3].curvePointType, CurvePointType.begin);
    expect(curvePoints[3].curveType, CurveType.curveAfterHalt);
    expect(curvePoints[3].comment, 'Kurve 5 after stop');
  });

  test('Test stop on demand is parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(6));
    expect(servicePoints[0].mandatoryStop, true);
    expect(servicePoints[1].mandatoryStop, true);
    expect(servicePoints[2].mandatoryStop, false);
    expect(servicePoints[3].mandatoryStop, true);
    expect(servicePoints[4].mandatoryStop, true);
    expect(servicePoints[5].mandatoryStop, true);
  });

  test('Test passing point is parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(6));
    expect(servicePoints[0].isStop, true);
    expect(servicePoints[1].isStop, false);
    expect(servicePoints[2].isStop, true);
    expect(servicePoints[3].isStop, true);
    expect(servicePoints[4].isStop, true);
    expect(servicePoints[5].isStop, true);
  });

  test('Test station point is parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(6));
    expect(servicePoints[0].isStation, true);
    expect(servicePoints[1].isStation, true);
    expect(servicePoints[2].isStation, false);
    expect(servicePoints[3].isStation, true);
    expect(servicePoints[4].isStation, true);
    expect(servicePoints[5].isStation, true);
  });

  test('Test bracket stations is parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();

    expect(journey.valid, true);
    expect(servicePoints, hasLength(6));
    expect(servicePoints[0].bracketMainStation, isNull);
    expect(servicePoints[1].bracketMainStation, isNull);
    expect(servicePoints[2].bracketMainStation, isNull);
    expect(servicePoints[3].bracketMainStation, isNotNull);
    expect(servicePoints[3].bracketMainStation!.abbreviation, 'D');
    expect(servicePoints[4].bracketMainStation, isNotNull);
    expect(servicePoints[4].bracketMainStation!.abbreviation, 'D');
    expect(servicePoints[5].bracketMainStation, isNull);
  });

  test('Test protection section is parsed correctly', () async {
    final journey = getJourney('T3', 1);
    final protectionSections =
        journey.data.where((it) => it.type == Datatype.protectionSection).cast<ProtectionSection>().toList();

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
    final journey = getJourney('T3', 1);
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

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
    final journey = getJourney('T2', 3);
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

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
    final journey = getJourney('T3', 1, jpPostfix: 'asp_no_date');
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

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
    final journey = getJourney('T3', 1, jpPostfix: 'asp_date_before');
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(0));
    expect(journey.metadata.additionalSpeedRestrictions, hasLength(0));
  });

  test('Test additional speed restriction with date in the future', () async {
    final journey = getJourney('T3', 1, jpPostfix: 'asp_date_after');
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(0));
    expect(journey.metadata.additionalSpeedRestrictions, hasLength(0));
  });

  test('Test speed change is parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    final speedChanges = journey.data.where((it) => it.type == Datatype.speedChange).cast<SpeedChange>().toList();

    expect(journey.valid, true);
    expect(speedChanges, hasLength(2));
    expect(speedChanges[0].text, 'Zahnstangen Anfang');
    expect(speedChanges[0].speedData!.speeds, hasLength(2));
    expect(speedChanges[0].speedData!.speeds[0].trainSeries, TrainSeries.R);
    expect(speedChanges[0].speedData!.speeds[0].incomingSpeeds[0].speed, 55);
    expect(speedChanges[0].speedData!.speeds[0].reduced, true);
    expect(speedChanges[0].speedData!.speeds[0].breakSeries, 100);
    expect(speedChanges[0].speedData!.speeds[1].trainSeries, TrainSeries.A);
    expect(speedChanges[0].speedData!.speeds[1].incomingSpeeds[0].speed, 50);
    expect(speedChanges[0].speedData!.speeds[1].reduced, false);
    expect(speedChanges[0].speedData!.speeds[1].breakSeries, 30);
    expect(speedChanges[1].text, 'Zahnstangen Ende');
    expect(speedChanges[1].speedData!.speeds, hasLength(2));
    expect(speedChanges[1].speedData!.speeds[0].trainSeries, TrainSeries.R);
    expect(speedChanges[1].speedData!.speeds[0].incomingSpeeds[0].speed, 80);
    expect(speedChanges[1].speedData!.speeds[0].reduced, false);
    expect(speedChanges[1].speedData!.speeds[0].breakSeries, 100);
    expect(speedChanges[1].speedData!.speeds[1].trainSeries, TrainSeries.A);
    expect(speedChanges[1].speedData!.speeds[1].incomingSpeeds[0].speed, 80);
    expect(speedChanges[1].speedData!.speeds[1].reduced, false);
    expect(speedChanges[1].speedData!.speeds[1].breakSeries, 30);
  });

  test('Test connection tracks are parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    final connectionTracks =
        journey.data.where((it) => it.type == Datatype.connectionTrack).cast<ConnectionTrack>().toList();

    expect(journey.valid, true);
    expect(connectionTracks, hasLength(3));
    expect(connectionTracks[0].text, isNull);
    expect(connectionTracks[0].speedData, isNull);
    expect(connectionTracks[1].text, 'AnG. WITZ');
    expect(connectionTracks[1].speedData, isNull);
    expect(connectionTracks[2].text, '22-6 Uhr');
    expect(connectionTracks[2].speedData, isNotNull);
    expect(connectionTracks[2].speedData!.speeds, hasLength(2));
    expect(connectionTracks[2].speedData!.speeds[0].trainSeries, TrainSeries.R);
    expect(connectionTracks[2].speedData!.speeds[0].incomingSpeeds[0].speed, 45);
    expect(connectionTracks[2].speedData!.speeds[0].reduced, false);
    expect(connectionTracks[2].speedData!.speeds[0].breakSeries, isNull);
    expect(connectionTracks[2].speedData!.speeds[1].trainSeries, TrainSeries.A);
    expect(connectionTracks[2].speedData!.speeds[1].incomingSpeeds[0].speed, 40);
    expect(connectionTracks[2].speedData!.speeds[1].reduced, false);
    expect(connectionTracks[2].speedData!.speeds[1].breakSeries, isNull);
  });

  test('Test available break series are parsed correctly', () async {
    var journey = getJourney('T9999', 5);
    expect(journey.valid, true);
    expect(journey.metadata.availableBreakSeries, hasLength(3));
    expect(journey.metadata.availableBreakSeries.elementAt(0).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(0).breakSeries, 150);
    expect(journey.metadata.availableBreakSeries.elementAt(1).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(1).breakSeries, 100);
    expect(journey.metadata.availableBreakSeries.elementAt(2).trainSeries, TrainSeries.A);
    expect(journey.metadata.availableBreakSeries.elementAt(2).breakSeries, 30);

    journey = getJourney('T5', 1);
    expect(journey.valid, true);
    expect(journey.metadata.availableBreakSeries, hasLength(16));
    expect(journey.metadata.availableBreakSeries.elementAt(0).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(0).breakSeries, 105);
    expect(journey.metadata.availableBreakSeries.elementAt(5).trainSeries, TrainSeries.A);
    expect(journey.metadata.availableBreakSeries.elementAt(5).breakSeries, 50);
    expect(journey.metadata.availableBreakSeries.elementAt(15).trainSeries, TrainSeries.D);
    expect(journey.metadata.availableBreakSeries.elementAt(15).breakSeries, 30);

    journey = getJourney('T8', 1);
    expect(journey.valid, true);
    expect(journey.metadata.availableBreakSeries, hasLength(3));
    expect(journey.metadata.availableBreakSeries.elementAt(0).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(0).breakSeries, 115);
    expect(journey.metadata.availableBreakSeries.elementAt(1).trainSeries, TrainSeries.N);
    expect(journey.metadata.availableBreakSeries.elementAt(1).breakSeries, 50);
    expect(journey.metadata.availableBreakSeries.elementAt(2).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(2).breakSeries, 150);
  });

  test('Test station/curve speeds are parsed correctly', () async {
    final journey = getJourney('T5', 1);
    expect(journey.valid, true);

    final curvePoints = journey.data.where((it) => it.type == Datatype.curvePoint).cast<CurvePoint>().toList();
    expect(curvePoints, hasLength(3));
    expect(curvePoints[0].localSpeedData, isNotNull);
    expect(curvePoints[0].localSpeedData!.speeds, hasLength(3));
    expect(curvePoints[1].localSpeedData, isNotNull);
    expect(curvePoints[1].localSpeedData!.speeds, hasLength(2));
    expect(curvePoints[2].localSpeedData, isNull);

    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();
    expect(servicePoints, hasLength(3));
    expect(servicePoints[0].speedData, isNotNull);
    expect(servicePoints[0].speedData!.speeds, hasLength(16));
    expect(servicePoints[1].speedData, isNotNull);
    expect(servicePoints[1].speedData!.speeds, hasLength(6));
    expect(servicePoints[2].speedData, isNotNull);
    expect(servicePoints[2].speedData!.speeds, hasLength(16));
  });

  test('Test train characteristics break series is parsed correctly', () async {
    final journey = getJourney('T5', 1, tcCount: 1);
    expect(journey.valid, true);
    expect(journey.metadata.breakSeries, isNotNull);
    expect(journey.metadata.breakSeries!.trainSeries, TrainSeries.R);
    expect(journey.metadata.breakSeries!.breakSeries, 115);
  });

  test('Test correct conversion from String to duration with the delay being PT0M25S', () async {
    final delay = DelayDto(attributes: {'Delay': 'PT0M25S'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNotNull);
    expect(convertedDelay!.isNegative, false);
    expect(convertedDelay.inMinutes, 0);
    expect(convertedDelay.inSeconds, 25);
  });

  test('Test correct conversion from String to duration with negative delay', () async {
    final delay = DelayDto(attributes: {'Delay': '-PT3M5S'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNotNull);
    expect(convertedDelay!.isNegative, true);
    expect(convertedDelay.inMinutes, -3);
    expect(convertedDelay.inSeconds, -185);
  });

  test('Test null delay conversion to null duration', () async {
    final delay = DelayDto();
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNull);
  });

  test('Test empty String conversion to null duration', () async {
    final delay = DelayDto(attributes: {'Delay': ''});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNull);
  });

  test('Test big delay String over one hour conversion to correct duration', () async {
    final delay = DelayDto(attributes: {'Delay': 'PT5H45M20S'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNotNull);
    expect(convertedDelay!.isNegative, false);
    expect(convertedDelay.inHours, 5);
    expect(convertedDelay.inMinutes, 345);
    expect(convertedDelay.inSeconds, 20720);
  });

  test('Test only seconds conversion to correct duration', () async {
    final delay = DelayDto(attributes: {'Delay': 'PT14S'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNotNull);
    expect(convertedDelay!.isNegative, false);
    expect(convertedDelay.inSeconds, 14);
  });

  test('Test wrong ISO 8601 format String conversion to null duration', () async {
    final delay = DelayDto(attributes: {'Delay': '+PTH45S3434M334'});
    final Duration? convertedDelay = delay.delayAsDuration;
    expect(convertedDelay, isNull);
  });

  test('Test tram area parsed correctly', () async {
    final journey = getJourney('T7', 1, tcCount: 1);
    expect(journey.valid, true);

    final tramAreas = journey.data.where((it) => it.type == Datatype.tramArea).cast<TramArea>().toList();
    expect(tramAreas, hasLength(1));
    expect(tramAreas[0].order, 900);
    expect(tramAreas[0].kilometre[0], 37.8);
    expect(tramAreas[0].amountTramSignals, 6);
    expect(tramAreas[0].endKilometre, 36.8);
  });

  test('Test whistle parsed correctly', () async {
    final journey = getJourney('T7', 1, tcCount: 1);
    expect(journey.valid, true);

    final whistles = journey.data.where((it) => it.type == Datatype.whistle).cast<Whistle>().toList();
    expect(whistles, hasLength(1));
    expect(whistles[0].order, 610);
    expect(whistles[0].kilometre[0], 39.600);
  });

  test('Test balise parsed correctly', () async {
    final journey = getJourney('T7', 1, tcCount: 1);
    expect(journey.valid, true);

    final balises = journey.data.where((it) => it.type == Datatype.balise).cast<Balise>().toList();
    expect(balises, hasLength(8));
    expect(balises[0].order, 600);
    expect(balises[0].kilometre[0], 41.552);
    expect(balises[0].amountLevelCrossings, 1);
    expect(balises[1].order, 602);
    expect(balises[1].kilometre[0], 41.190);
    expect(balises[1].amountLevelCrossings, 1);

    expect(balises[2].order, 604);
    expect(balises[2].amountLevelCrossings, 1);
    expect(balises[3].order, 606);
    expect(balises[3].amountLevelCrossings, 1);
    expect(balises[4].order, 608);
    expect(balises[4].amountLevelCrossings, 1);

    expect(balises[5].order, 611);
    expect(balises[5].amountLevelCrossings, 1);
    expect(balises[6].order, 613);
    expect(balises[6].amountLevelCrossings, 2);
    expect(balises[7].order, 616);
    expect(balises[7].amountLevelCrossings, 1);
  });

  test('Test level crossing parsed correctly', () async {
    final journey = getJourney('T7', 1, tcCount: 1);
    expect(journey.valid, true);

    final levelCrossings = journey.data.where((it) => it.type == Datatype.levelCrossing).cast<LevelCrossing>().toList();
    expect(levelCrossings, hasLength(12));
    expect(levelCrossings[0].order, 601);
    expect(levelCrossings[0].kilometre[0], 41.492);
    expect(levelCrossings[1].order, 603);
    expect(levelCrossings[1].kilometre[0], 41.155);
    expect(levelCrossings[2].order, 605);
    expect(levelCrossings[3].order, 607);
    expect(levelCrossings[4].order, 609);
    expect(levelCrossings[5].order, 612);
    expect(levelCrossings[6].order, 614);
    expect(levelCrossings[7].order, 615);
    expect(levelCrossings[8].order, 617);
    expect(levelCrossings[9].order, 1600);
    expect(levelCrossings[10].order, 1601);
    expect(levelCrossings[11].order, 1602);
  });

  test('Test station speeds are parsed correctly', () async {
    final journey = getJourney('T8', 1);
    expect(journey.valid, true);

    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();
    expect(servicePoints, hasLength(4));

    // check ServicePoint Bern

    expect(servicePoints[0].localSpeedData, isNotNull);
    final graduatedStationSpeeds1 = servicePoints[0].localSpeedData!.speeds;
    expect(graduatedStationSpeeds1, hasLength(4));

    final rSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry1, isNotNull);
    expect(rSpeedEntry1!.text, isNull);
    expect(rSpeedEntry1.trainSeries, TrainSeries.R);
    expect(rSpeedEntry1.incomingSpeeds, hasLength(3));
    _checkSpeed(rSpeedEntry1.incomingSpeeds[0], 75);
    _checkSpeed(rSpeedEntry1.incomingSpeeds[1], 70);
    _checkSpeed(rSpeedEntry1.incomingSpeeds[2], 60);
    expect(rSpeedEntry1.outgoingSpeeds, isEmpty);

    final oSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry1, isNotNull);
    expect(oSpeedEntry1!.text, isNull);
    expect(oSpeedEntry1.trainSeries, TrainSeries.O);
    expect(oSpeedEntry1.incomingSpeeds, hasLength(3));
    _checkSpeed(oSpeedEntry1.incomingSpeeds[0], 75);
    _checkSpeed(oSpeedEntry1.incomingSpeeds[1], 70);
    _checkSpeed(oSpeedEntry1.incomingSpeeds[2], 60);
    expect(oSpeedEntry1.outgoingSpeeds, isEmpty);

    final sSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.S);
    expect(sSpeedEntry1, isNotNull);
    expect(sSpeedEntry1!.text, isNull);
    expect(sSpeedEntry1.trainSeries, TrainSeries.S);
    expect(sSpeedEntry1.incomingSpeeds, hasLength(2));
    _checkSpeed(sSpeedEntry1.incomingSpeeds[0], 70);
    _checkSpeed(sSpeedEntry1.incomingSpeeds[1], 60);
    expect(sSpeedEntry1.outgoingSpeeds, hasLength(1));
    _checkSpeed(sSpeedEntry1.outgoingSpeeds[0], 50);

    final nSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry1, isNotNull);
    expect(nSpeedEntry1!.text, isNull);
    expect(nSpeedEntry1.trainSeries, TrainSeries.N);
    expect(nSpeedEntry1.incomingSpeeds, hasLength(1));
    _checkSpeed(nSpeedEntry1.incomingSpeeds[0], 70);
    expect(nSpeedEntry1.outgoingSpeeds, hasLength(1));
    _checkSpeed(nSpeedEntry1.outgoingSpeeds[0], 60);

    // check ServicePoint Wankdorf

    expect(servicePoints[1].localSpeedData, isNull);

    // check ServicePoint Burgdorf

    final graduatedStationSpeeds2 = servicePoints[2].localSpeedData!.speeds;
    expect(graduatedStationSpeeds2, hasLength(6));

    final rSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry2, isNotNull);
    expect(rSpeedEntry2!.text, isNull);
    expect(rSpeedEntry2.trainSeries, TrainSeries.R);
    expect(rSpeedEntry2.incomingSpeeds, hasLength(2));
    _checkSpeed(rSpeedEntry2.incomingSpeeds[0], 75);
    _checkSpeed(rSpeedEntry2.incomingSpeeds[1], 70, isCircled: true);
    expect(rSpeedEntry2.outgoingSpeeds, hasLength(1));
    _checkSpeed(rSpeedEntry2.outgoingSpeeds[0], 60, isSquared: true);

    final oSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry2, isNotNull);
    expect(oSpeedEntry2!.text, isNull);
    expect(oSpeedEntry2.trainSeries, TrainSeries.O);
    expect(oSpeedEntry2.incomingSpeeds, hasLength(2));
    _checkSpeed(oSpeedEntry2.incomingSpeeds[0], 75);
    _checkSpeed(oSpeedEntry2.incomingSpeeds[1], 70, isCircled: true);
    expect(oSpeedEntry2.outgoingSpeeds, hasLength(1));
    _checkSpeed(oSpeedEntry2.outgoingSpeeds[0], 60, isSquared: true);

    final aSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(aSpeedEntry2, isNotNull);
    expect(aSpeedEntry2!.text, isNull);
    expect(aSpeedEntry2.trainSeries, TrainSeries.A);
    expect(aSpeedEntry2.incomingSpeeds, hasLength(1));
    _checkSpeed(aSpeedEntry2.incomingSpeeds[0], 70);
    expect(aSpeedEntry2.outgoingSpeeds, isEmpty);

    final dSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.D);
    expect(dSpeedEntry2, isNotNull);
    expect(dSpeedEntry2!.text, isNull);
    expect(dSpeedEntry2.trainSeries, TrainSeries.D);
    expect(dSpeedEntry2.incomingSpeeds, hasLength(1));
    _checkSpeed(dSpeedEntry2.incomingSpeeds[0], 70);
    expect(dSpeedEntry2.outgoingSpeeds, isEmpty);

    // check ServicePoint Olten

    final graduatedStationSpeeds3 = servicePoints[3].localSpeedData!.speeds;
    expect(graduatedStationSpeeds3, hasLength(2));

    final nSpeedEntry3 = graduatedStationSpeeds3.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry3, isNotNull);
    expect(nSpeedEntry3!.text, isNull);
    expect(nSpeedEntry3.trainSeries, TrainSeries.N);
    expect(nSpeedEntry3.incomingSpeeds, hasLength(1));
    _checkSpeed(nSpeedEntry3.incomingSpeeds[0], 80);
    expect(nSpeedEntry3.outgoingSpeeds, hasLength(2));
    _checkSpeed(nSpeedEntry3.outgoingSpeeds[0], 70);
    _checkSpeed(nSpeedEntry3.outgoingSpeeds[1], 60);

    final sSpeedEntry3 = graduatedStationSpeeds3.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.S);
    expect(sSpeedEntry3, isNotNull);
    expect(sSpeedEntry3!.text, isNull);
    expect(sSpeedEntry3.trainSeries, TrainSeries.S);
    expect(sSpeedEntry3.incomingSpeeds, hasLength(2));
    _checkSpeed(sSpeedEntry3.incomingSpeeds[0], 70);
    _checkSpeed(sSpeedEntry3.incomingSpeeds[1], 60);
    expect(sSpeedEntry3.outgoingSpeeds, hasLength(1));
    _checkSpeed(sSpeedEntry3.outgoingSpeeds[0], 50);
  });

  test('Test graduated station speeds are parsed correctly', () async {
    final journey = getJourney('T8', 1);
    expect(journey.valid, true);

    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();
    expect(servicePoints, hasLength(4));

    // check ServicePoint Bern

    expect(servicePoints[0].graduatedSpeedInfo, isNotNull);
    final graduatedStationSpeeds1 = servicePoints[0].graduatedSpeedInfo!.speeds;
    expect(graduatedStationSpeeds1, hasLength(4));

    final rSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry1, isNotNull);
    expect(rSpeedEntry1!.text, 'Zusatzinformation A');
    expect(rSpeedEntry1.trainSeries, TrainSeries.R);
    expect(rSpeedEntry1.incomingSpeeds, hasLength(3));
    _checkSpeed(rSpeedEntry1.incomingSpeeds[0], 75);
    _checkSpeed(rSpeedEntry1.incomingSpeeds[1], 70);
    _checkSpeed(rSpeedEntry1.incomingSpeeds[2], 60);
    expect(rSpeedEntry1.outgoingSpeeds, isEmpty);

    final oSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry1, isNotNull);
    expect(oSpeedEntry1!.text, 'Zusatzinformation A');
    expect(oSpeedEntry1.trainSeries, TrainSeries.O);
    expect(oSpeedEntry1.incomingSpeeds, hasLength(3));
    _checkSpeed(oSpeedEntry1.incomingSpeeds[0], 75);
    _checkSpeed(oSpeedEntry1.incomingSpeeds[1], 70);
    _checkSpeed(oSpeedEntry1.incomingSpeeds[2], 60);
    expect(oSpeedEntry1.outgoingSpeeds, isEmpty);

    final sSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.S);
    expect(sSpeedEntry1, isNotNull);
    expect(sSpeedEntry1!.text, 'Zusatzinformation A');
    expect(sSpeedEntry1.trainSeries, TrainSeries.S);
    expect(sSpeedEntry1.incomingSpeeds, hasLength(2));
    _checkSpeed(sSpeedEntry1.incomingSpeeds[0], 70);
    _checkSpeed(sSpeedEntry1.incomingSpeeds[1], 60);
    expect(sSpeedEntry1.outgoingSpeeds, hasLength(1));
    _checkSpeed(sSpeedEntry1.outgoingSpeeds[0], 50);

    final nSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry1, isNotNull);
    expect(nSpeedEntry1!.text, 'Zusatzinformation B');
    expect(nSpeedEntry1.trainSeries, TrainSeries.N);
    expect(nSpeedEntry1.incomingSpeeds, hasLength(1));
    _checkSpeed(nSpeedEntry1.incomingSpeeds[0], 70);
    expect(nSpeedEntry1.outgoingSpeeds, hasLength(1));
    _checkSpeed(nSpeedEntry1.outgoingSpeeds[0], 60);

    final relevantSpeedInfo =
        servicePoints[0].relevantGraduatedSpeedInfo(BreakSeries(trainSeries: TrainSeries.N, breakSeries: 50));
    expect(relevantSpeedInfo, hasLength(1));
    expect(relevantSpeedInfo[0].text, 'Zusatzinformation B');
    expect(relevantSpeedInfo[0].trainSeries, TrainSeries.N);

    // check ServicePoint Wankdorf

    expect(servicePoints[1].graduatedSpeedInfo, isNull);

    // check ServicePoint Burgdorf

    final graduatedStationSpeeds2 = servicePoints[2].graduatedSpeedInfo!.speeds;
    expect(graduatedStationSpeeds2, hasLength(4));

    final rSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry2, isNotNull);
    expect(rSpeedEntry2!.text, 'Zusatzinformation A');
    expect(rSpeedEntry2.trainSeries, TrainSeries.R);
    expect(rSpeedEntry2.incomingSpeeds, hasLength(2));
    _checkSpeed(rSpeedEntry2.incomingSpeeds[0], 75);
    _checkSpeed(rSpeedEntry2.incomingSpeeds[1], 70, isCircled: true);
    expect(rSpeedEntry2.outgoingSpeeds, hasLength(1));
    _checkSpeed(rSpeedEntry2.outgoingSpeeds[0], 60, isSquared: true);

    final oSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry2, isNotNull);
    expect(oSpeedEntry2!.text, 'Zusatzinformation A');
    expect(oSpeedEntry2.trainSeries, TrainSeries.O);
    expect(oSpeedEntry2.incomingSpeeds, hasLength(2));
    _checkSpeed(oSpeedEntry2.incomingSpeeds[0], 75);
    _checkSpeed(oSpeedEntry2.incomingSpeeds[1], 70, isCircled: true);
    expect(oSpeedEntry2.outgoingSpeeds, hasLength(1));
    _checkSpeed(oSpeedEntry2.outgoingSpeeds[0], 60, isSquared: true);

    final aSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(aSpeedEntry2, isNotNull);
    expect(aSpeedEntry2!.text, 'Zusatzinformation B');
    expect(aSpeedEntry2.trainSeries, TrainSeries.A);
    expect(aSpeedEntry2.incomingSpeeds, hasLength(1));
    _checkSpeed(aSpeedEntry2.incomingSpeeds[0], 70);
    expect(aSpeedEntry2.outgoingSpeeds, isEmpty);

    final dSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.D);
    expect(dSpeedEntry2, isNotNull);
    expect(dSpeedEntry2!.text, 'Zusatzinformation B');
    expect(dSpeedEntry2.trainSeries, TrainSeries.D);
    expect(dSpeedEntry2.incomingSpeeds, hasLength(1));
    _checkSpeed(dSpeedEntry2.incomingSpeeds[0], 70);
    expect(dSpeedEntry2.outgoingSpeeds, isEmpty);

    // check ServicePoint Olten

    final graduatedStationSpeeds3 = servicePoints[3].graduatedSpeedInfo!.speeds;
    expect(graduatedStationSpeeds3, hasLength(2));

    final nSpeedEntry3 = graduatedStationSpeeds3.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry3, isNotNull);
    expect(nSpeedEntry3!.text, 'Zusatzinformation A');
    expect(nSpeedEntry3.trainSeries, TrainSeries.N);
    expect(nSpeedEntry3.incomingSpeeds, hasLength(1));
    _checkSpeed(nSpeedEntry3.incomingSpeeds[0], 80);
    expect(nSpeedEntry3.outgoingSpeeds, hasLength(2));
    _checkSpeed(nSpeedEntry3.outgoingSpeeds[0], 70);
    _checkSpeed(nSpeedEntry3.outgoingSpeeds[1], 60);

    final sSpeedEntry3 = graduatedStationSpeeds3.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.S);
    expect(sSpeedEntry3, isNotNull);
    expect(sSpeedEntry3!.text, 'Zusatzinformation A');
    expect(sSpeedEntry3.trainSeries, TrainSeries.S);
    expect(sSpeedEntry3.incomingSpeeds, hasLength(2));
    _checkSpeed(sSpeedEntry3.incomingSpeeds[0], 70);
    _checkSpeed(sSpeedEntry3.incomingSpeeds[1], 60);
    expect(sSpeedEntry3.outgoingSpeeds, hasLength(1));
    _checkSpeed(sSpeedEntry3.outgoingSpeeds[0], 50);
  });

  test('Test current position is start when nothing is given ', () async {
    var journey = getJourney('T9', 1, tcCount: 1);
    expect(journey.valid, true);
    expect(journey.metadata.currentPosition, journey.data.first);

    journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 0);
    expect(journey.valid, true);
    expect(journey.metadata.currentPosition, journey.data.first);
  });

  test('Test current position is set to signal', () async {
    var journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 1000);
    expect(journey.valid, true);
    expect(journey.metadata.currentPosition, journey.data[5]);

    journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 3000);
    expect(journey.valid, true);
    expect(journey.metadata.currentPosition, journey.data[18]);
  });

  test('Test current position is set to service point on last signal', () async {
    var journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 2000);
    expect(journey.valid, true);
    expect(journey.metadata.currentPosition, journey.data.whereType<ServicePoint>().toList()[1]);

    journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 4000);
    expect(journey.valid, true);
    expect(journey.metadata.currentPosition, journey.data.whereType<ServicePoint>().toList()[2]);
  });

  test('Test next station is calculated correctly with non position infos ', () async {
    final journey = getJourney('T9', 1, tcCount: 1);
    expect(journey.valid, true);
    expect(journey.metadata.nextStop, journey.data.whereType<ServicePoint>().toList()[1]);
  });

  test('Test next station is calculated correctly with related train info', () async {
    final journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 2000);
    expect(journey.valid, true);
    expect(journey.metadata.nextStop, journey.data.whereType<ServicePoint>().toList()[2]);
  });

  test('Test use last position on invalid position update', () async {
    final journey1 = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 1000);
    expect(journey1.valid, true);
    expect(journey1.metadata.currentPosition, journey1.data[5]);
    expect(journey1.metadata.nextStop, journey1.data.whereType<ServicePoint>().toList()[1]);

    final journey2 = getJourney(
      'T9',
      1,
      tcCount: 1,
      relatedTrainInfoEventId: -1,
      lastJourney: journey1,
    );
    expect(journey2.metadata.currentPosition, journey2.data[5]);
    expect(journey2.metadata.nextStop, journey2.data.whereType<ServicePoint>().toList()[1]);
  });

  test('Test last service point is calculated correctly with non position infos', () async {
    final journey = getJourney('T9', 1, tcCount: 1);
    expect(journey.valid, true);
    expect(journey.metadata.lastServicePoint, journey.data.whereType<ServicePoint>().toList()[0]);
  });

  test('Test last service point is calculated correctly when no other service point driven over', () async {
    final journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 2000);
    expect(journey.valid, true);
    expect(journey.metadata.lastServicePoint, journey.data.whereType<ServicePoint>().toList()[0]);
  });

  test('Test last service point is calculated correctly with non position infos', () async {
    final journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 3000);
    expect(journey.valid, true);
    expect(journey.metadata.lastServicePoint, journey.data.whereType<ServicePoint>().toList()[1]);
  });

  test('Test last service point is correct with invalid position update', () async {
    final journey1 = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 3000);
    expect(journey1.valid, true);
    expect(journey1.metadata.currentPosition, journey1.data[18]);
    expect(journey1.metadata.lastServicePoint, journey1.data.whereType<ServicePoint>().toList()[1]);

    final journey2 = getJourney(
      'T9',
      1,
      tcCount: 1,
      relatedTrainInfoEventId: -1,
      lastJourney: journey1,
    );
    expect(journey2.metadata.currentPosition, journey2.data[18]);
    expect(journey2.metadata.lastServicePoint, journey2.data.whereType<ServicePoint>().toList()[1]);
  });

  test('Test CommunicationNetworks parsed correctly', () async {
    final journey = getJourney('T12', 1);
    expect(journey.valid, true);

    final networkChanges = journey.metadata.communicationNetworkChanges;
    expect(networkChanges, hasLength(3));
    expect(networkChanges[0].order, 1000);
    expect(networkChanges[0].type, CommunicationNetworkType.gsmP);
    expect(networkChanges[1].order, 1500);
    expect(networkChanges[1].type, CommunicationNetworkType.sim);
    expect(networkChanges[2].order, 2000);
    expect(networkChanges[2].type, CommunicationNetworkType.gsmR);
  });

  test('Test opFootNote parsed correctly', () async {
    final journey = getJourney('T15', 4);
    expect(journey.valid, true);

    final opFootNotes = journey.data.whereType<OpFootNote>().toList();
    expect(opFootNotes, hasLength(3));
    expect(opFootNotes[0].footNote.type, FootNoteType.decisiveGradientDown);
    expect(opFootNotes[0].footNote.text, 'Renens - Lausanne <i>"via saut-de-mouton"</i> 0‰');
    expect(opFootNotes[0].footNote.refText, '1)');
    expect(opFootNotes[1].footNote.type, FootNoteType.contact);
    expect(opFootNotes[1].footNote.text,
        'Das ist <b>fett <i>und kursiv</i></b> <br/>und das ist <br/><i>noch kursiv</i>.');
    expect(opFootNotes[1].footNote.refText, '1)');
    expect(opFootNotes[2].footNote.type, FootNoteType.contact);
    expect(opFootNotes[2].footNote.text, '+41 512 800 506 RBC Lavaux');
    expect(opFootNotes[2].footNote.refText, '1)');
  });

  test('Test lineFootNote parsed correctly', () async {
    final journey = getJourney('T15', 4);
    expect(journey.valid, true);

    final lineFootNotes = journey.data.whereType<LineFootNote>().toList();
    expect(lineFootNotes, hasLength(3));
    expect(lineFootNotes[0].footNote.type, isNull);
    expect(lineFootNotes[0].footNote.identifier, '072869607d536b607a61111cf910784a');
    expect(lineFootNotes[0].footNote.text, 'admis seulement pour <b>RABe 503, ETR 610</b>');
    expect(lineFootNotes[0].footNote.trainSeries, [TrainSeries.N]);
    expect(lineFootNotes[0].locationName, 'Lausanne');
    expect(lineFootNotes[1].footNote.type, isNull);
    expect(lineFootNotes[1].footNote.identifier, '072869607d536b607a61111cf910784a');
    expect(lineFootNotes[1].footNote.text, 'admis seulement pour <b>RABe 503, ETR 610</b>');
    expect(lineFootNotes[1].footNote.trainSeries, [TrainSeries.N]);
    expect(lineFootNotes[1].locationName, 'Pully');
    expect(lineFootNotes[2].footNote.type, isNull);
    expect(lineFootNotes[2].footNote.identifier, '072869607d536b607a61111cf910784a');
    expect(lineFootNotes[2].footNote.text, 'admis seulement pour <b>RABe 503, ETR 610</b>');
    expect(lineFootNotes[2].footNote.trainSeries, [TrainSeries.N]);
    expect(lineFootNotes[2].locationName, 'Taillepied');

    expect(journey.metadata.lineFootNoteLocations, hasLength(1));
    expect(journey.metadata.lineFootNoteLocations['072869607d536b607a61111cf910784a'], hasLength(3));
    expect(journey.metadata.lineFootNoteLocations['072869607d536b607a61111cf910784a']![0], 'Lausanne');
    expect(journey.metadata.lineFootNoteLocations['072869607d536b607a61111cf910784a']![1], 'Pully');
    expect(journey.metadata.lineFootNoteLocations['072869607d536b607a61111cf910784a']![2], 'Taillepied');
  });

  test('Test trackFootNote parsed correctly', () async {
    final journey = getJourney('T15', 4);
    expect(journey.valid, true);

    final trackFootNotes = journey.data.whereType<TrackFootNote>().toList();
    expect(trackFootNotes, hasLength(1));
    expect(trackFootNotes[0].footNote.type, FootNoteType.journey);
    expect(trackFootNotes[0].footNote.text, 'TrackFootNote nur für R');
    expect(trackFootNotes[0].footNote.trainSeries, hasLength(1));
    expect(trackFootNotes[0].footNote.trainSeries[0], TrainSeries.R);
    expect(trackFootNotes[0].footNote.refText, '1)');
  });

  test('Test ContactList T9999 parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    expect(journey.valid, true);

    final radioContactLists = journey.metadata.radioContactLists.toList();

    expect(radioContactLists.length, 5);
    expect(radioContactLists[0].mainContacts.length, 1);
    expect(radioContactLists[0].mainContacts.first.contactIdentifier, '1304');
    expect(radioContactLists[1].mainContacts.length, 1);
    expect(radioContactLists[1].mainContacts.first.contactIdentifier, '(1305)');
    expect(radioContactLists[2].mainContacts.length, 1);
    expect(radioContactLists[2].selectiveContacts.length, 3);
    expect(radioContactLists[2].selectiveContacts.first.contactIdentifier, '1302');
    expect(radioContactLists[2].selectiveContacts.first.contactRole, 'Richtung Süd: Fahrdienstleiter');
    expect(radioContactLists[3].mainContacts.first.contactIdentifier, '1304');
    expect(radioContactLists[4].mainContacts.first.contactIdentifier, '(1305)');
  });

  test('Test ContactList T12 parsed correctly', () async {
    final journey = getJourney('T12', 1);
    expect(journey.valid, true);

    final radioContactLists = journey.metadata.radioContactLists.toList();

    expect(radioContactLists.length, 3);
    expect(radioContactLists[0].mainContacts.length, 1);
    expect(radioContactLists[0].mainContacts.first.contactIdentifier, '1407');
    expect(radioContactLists[1].mainContacts.length, 3);
    expect(radioContactLists[1].mainContacts.first.contactIdentifier, '1608');
    expect(radioContactLists[2].mainContacts.length, 1);
    expect(radioContactLists[2].selectiveContacts.length, 3);
    expect(radioContactLists[2].selectiveContacts.first.contactIdentifier, '1103');
    expect(radioContactLists[2].selectiveContacts.first.contactRole, 'Richtung Süd: Fahrdienstleiter');
  });

  test('Test DecisiveGradientArea parsed correctly', () {
    final journey = getJourney('T15', 4);
    expect(journey.valid, true);

    final servicePoints = journey.data.whereType<ServicePoint>().toList();

    expect(servicePoints, hasLength(4));
    expect(servicePoints[0].decisiveGradient, isNotNull);
    expect(servicePoints[0].decisiveGradient!.uphill, isNull);
    expect(servicePoints[0].decisiveGradient!.downhill, 10.0);
    expect(servicePoints[1].decisiveGradient, isNull);
    expect(servicePoints[2].decisiveGradient, isNotNull);
    expect(servicePoints[2].decisiveGradient!.uphill, 11.0);
    expect(servicePoints[2].decisiveGradient!.downhill, isNull);
    expect(servicePoints[3].decisiveGradient, isNotNull);
    expect(servicePoints[3].decisiveGradient!.uphill, 3.0);
    expect(servicePoints[3].decisiveGradient!.downhill, 8.0);
  });

  test('Test ArrivalDepartureTime parsed correctly in near time', () {
    final journey = getJourney('T16', 1);
    expect(journey.valid, true);

    final servicePoints = journey.data.whereType<ServicePoint>().toList();
    expect(servicePoints, hasLength(8));

    // has calculated times
    expect(journey.metadata.anyOperationalArrivalDepartureTimes, isTrue);

    // ambiguousDepartureTime and plannedOperationalDepartureTime
    final genevaAirport = servicePoints[0];
    expect(genevaAirport.arrivalDepartureTime, isNotNull);
    expect(genevaAirport.arrivalDepartureTime!.operationalDepartureTime, DateTime.parse('2025-05-12T16:14:25Z'));
    expect(genevaAirport.arrivalDepartureTime!.plannedDepartureTime, DateTime.parse('2025-05-12T15:13:40Z'));
    expect(genevaAirport.arrivalDepartureTime!.hasAnyOperationalTime, isTrue);
    // single ambiguousDepartureTime ('time not calculated')
    final geneva = servicePoints[1];
    expect(geneva.arrivalDepartureTime, isNotNull);
    expect(geneva.arrivalDepartureTime!.operationalDepartureTime, isNull);
    expect(geneva.arrivalDepartureTime!.plannedDepartureTime, DateTime.parse('2025-05-12T15:24:25Z'));
    expect(geneva.arrivalDepartureTime!.hasAnyOperationalTime, isFalse);
    // ambiguousDepartureTime and plannedOperationalDepartureTime
    final nyon = servicePoints[2];
    expect(nyon.arrivalDepartureTime, isNotNull);
    expect(nyon.arrivalDepartureTime!.operationalDepartureTime, DateTime.parse('2025-05-12T16:39:59Z'));
    expect(nyon.arrivalDepartureTime!.plannedDepartureTime, DateTime.parse('2025-05-12T15:39:43Z'));
    expect(nyon.arrivalDepartureTime!.hasAnyOperationalTime, isTrue);
    // single ambiguousArrivalTime
    final morges = servicePoints[3];
    expect(morges.arrivalDepartureTime, isNotNull);
    expect(morges.arrivalDepartureTime!.operationalDepartureTime, isNull);
    expect(morges.arrivalDepartureTime!.plannedDepartureTime, isNull);
    expect(morges.arrivalDepartureTime!.operationalArrivalTime, isNull);
    expect(morges.arrivalDepartureTime!.plannedArrivalTime, DateTime.parse('2025-05-12T15:55:23Z'));
    // ambiguousArrivalTime and plannedArrivalTime
    final lausanne = servicePoints[4];
    expect(lausanne.arrivalDepartureTime, isNotNull);
    expect(lausanne.arrivalDepartureTime!.operationalDepartureTime, isNull);
    expect(lausanne.arrivalDepartureTime!.plannedDepartureTime, isNull);
    expect(lausanne.arrivalDepartureTime!.operationalArrivalTime, DateTime.parse('2025-05-12T17:07:12Z'));
    expect(lausanne.arrivalDepartureTime!.plannedArrivalTime, DateTime.parse('2025-05-12T16:07:20Z'));
    expect(lausanne.arrivalDepartureTime!.hasAnyOperationalTime, isTrue);
    // ambiguousArrivalTime, plannedArrivalTime and ambiguousDepartureTime
    final vevey = servicePoints[5];
    expect(vevey.arrivalDepartureTime, isNotNull);
    expect(vevey.arrivalDepartureTime!.operationalDepartureTime, isNull);
    expect(vevey.arrivalDepartureTime!.plannedDepartureTime, DateTime.parse('2025-05-12T16:29:12Z'));
    expect(vevey.arrivalDepartureTime!.operationalArrivalTime, DateTime.parse('2025-05-12T17:28:56Z'));
    expect(vevey.arrivalDepartureTime!.plannedArrivalTime, DateTime.parse('2025-05-12T16:28:12Z'));
    expect(vevey.arrivalDepartureTime!.hasAnyOperationalTime, isTrue);
    // all times
    final montreux = servicePoints[6];
    expect(montreux.arrivalDepartureTime, isNotNull);
    expect(montreux.arrivalDepartureTime!.operationalDepartureTime, DateTime.parse('2025-05-12T17:36:42Z'));
    expect(montreux.arrivalDepartureTime!.plannedDepartureTime, DateTime.parse('2025-05-12T16:36:12Z'));
    expect(montreux.arrivalDepartureTime!.operationalArrivalTime, DateTime.parse('2025-05-12T17:35:16Z'));
    expect(montreux.arrivalDepartureTime!.plannedArrivalTime, DateTime.parse('2025-05-12T16:35:12Z'));
    expect(montreux.arrivalDepartureTime!.hasAnyOperationalTime, isTrue);
    // none again
    final aigle = servicePoints[7];
    expect(aigle.arrivalDepartureTime, isNull);
  });

  test('metadata.hasCalculatedTimes_whenNoCalculatedTimesInJourney_thenFalse', () {
    final journey = getJourney('T4', 1);
    expect(journey.valid, true);

    // has calculated times
    expect(journey.metadata.anyOperationalArrivalDepartureTimes, isFalse);
  });

  test('metadata.hasCalculatedTimes_whenNoTimesInJourney_thenFalse', () {
    final journey = getJourney('T5', 1);
    expect(journey.valid, true);

    // has calculated times
    expect(journey.metadata.anyOperationalArrivalDepartureTimes, isFalse);
  });
}

void _checkSpeed(Speed speed, int speedValue, {bool isCircled = false, bool isSquared = false}) {
  expect(speed.speed, speedValue);
  expect(speed.isCircled, isCircled);
  expect(speed.isSquared, isSquared);
}
