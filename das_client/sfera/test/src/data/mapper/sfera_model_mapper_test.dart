import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/component.dart';
import 'package:logging/logging.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/delay_dto.dart';
import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/related_train_information_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';
import 'package:sfera/src/model/journey/advised_speed_segment.dart';

void main() {
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen(LogPrinter(appName: 'DAS Tests', isDebugMode: true).call);

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
      lastJourney: lastJourney,
    );
  }

  test('returns null delay when delay is missing in event', () {
    final journey = getJourney('T8', 1);
    expect(journey.valid, true);

    final delay = journey.metadata.delay;

    expect(delay, isNull);
  });

  test('return valid delay when location and delay are given', () {
    final journey = getJourney('T9999', 5, relatedTrainInfoEventId: 2000);
    expect(journey.valid, true);

    final delay = journey.metadata.delay;

    expect(delay, isNotNull);
    final delayValue = delay!.value;
    expect(delayValue, Duration(seconds: 30));

    final location = delay.location;
    expect(location, 'T9999_1500.0');
  });

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
      journey.metadata.nonStandardTrackEquipmentSegments[0].type,
      TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
    );
    expect(journey.metadata.nonStandardTrackEquipmentSegments[0].startOrder, isNull);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[0].endOrder, 1600);
    expect(
      journey.metadata.nonStandardTrackEquipmentSegments[1].type,
      TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment,
    );
    expect(journey.metadata.nonStandardTrackEquipmentSegments[1].startOrder, 1700);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[1].endOrder, 2300);
    expect(
      journey.metadata.nonStandardTrackEquipmentSegments[2].type,
      TrackEquipmentType.etcsL2ConvSpeedReversingImpossible,
    );
    expect(journey.metadata.nonStandardTrackEquipmentSegments[2].startOrder, 102500);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[2].endOrder, 103700);
    expect(
      journey.metadata.nonStandardTrackEquipmentSegments[3].type,
      TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
    );
    expect(journey.metadata.nonStandardTrackEquipmentSegments[3].startOrder, 103700);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[3].endOrder, 307000);
    expect(
      journey.metadata.nonStandardTrackEquipmentSegments[4].type,
      TrackEquipmentType.etcsL2ConvSpeedReversingImpossible,
    );
    expect(journey.metadata.nonStandardTrackEquipmentSegments[4].startOrder, 307000);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[4].endOrder, 307800);
    expect(
      journey.metadata.nonStandardTrackEquipmentSegments[5].type,
      TrackEquipmentType.etcsL2ExtSpeedReversingImpossible,
    );
    expect(journey.metadata.nonStandardTrackEquipmentSegments[5].startOrder, 409200);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[5].endOrder, 410200);
    expect(
      journey.metadata.nonStandardTrackEquipmentSegments[6].type,
      TrackEquipmentType.etcsL2ExtSpeedReversingPossible,
    );
    expect(journey.metadata.nonStandardTrackEquipmentSegments[6].startOrder, 410200);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[6].endOrder, isNull);
  });

  test('Test speed change on CAB signaling end is generated correctly', () async {
    final journey = getJourney('T1', 5);

    expect(journey.valid, true);

    final cabSignaling = journey.data.where((it) => it.type == Datatype.cabSignaling).cast<CABSignaling>();
    final endSignaling = cabSignaling.where((signaling) => signaling.isEnd).toList();

    expect(endSignaling, hasLength(2));
    expect(endSignaling[0].speeds, isNotNull);
    expect(endSignaling[1].speeds, isNotNull);
    final speedSignal0 = endSignaling[0].speeds!.first;
    _checkTrainSeriesSpeed<SingleSpeed>(speedSignal0, expected: '55', trainSeries: TrainSeries.R, breakSeries: 115);
    final speedSignal1 = endSignaling[1].speeds!.first;
    _checkTrainSeriesSpeed<SingleSpeed>(speedSignal1, expected: '80', trainSeries: TrainSeries.R, breakSeries: 115);
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
    final protectionSections = journey.data
        .where((it) => it.type == Datatype.protectionSection)
        .cast<ProtectionSection>()
        .toList();

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
    expect(speedRestrictions, hasLength(7));
    expect(speedRestrictions[0].speed, 60);
    expect(speedRestrictions[0].kmFrom, 64.2);
    expect(speedRestrictions[0].kmTo, 63.2);
    expect(speedRestrictions[0].order, 700);
    expect(speedRestrictions[0].restrictions, hasLength(1));
    expect(speedRestrictions[0].restrictions[0].kmFrom, 64.2);
    expect(speedRestrictions[0].restrictions[0].kmTo, 63.2);
    expect(speedRestrictions[0].restrictions[0].orderFrom, 700);
    expect(speedRestrictions[0].restrictions[0].orderTo, 800);
    expect(speedRestrictions[0].restrictions[0].speed, 60);
    expect(speedRestrictions[0].restrictions[0].restrictionFrom, DateTime.parse('2022-01-01T00:00:00Z'));
    expect(speedRestrictions[0].restrictions[0].restrictionUntil, DateTime.parse('2060-01-01T00:00:00Z'));
    expect(speedRestrictions[0].restrictions[0].reason?.de, 'Schutz Personal');

    expect(journey.metadata.additionalSpeedRestrictions, hasLength(7));
    expect(journey.metadata.additionalSpeedRestrictions[0].kmFrom, 64.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].kmTo, 63.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderFrom, 700);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderTo, 800);
    expect(journey.metadata.additionalSpeedRestrictions[0].speed, 60);
    expect(journey.metadata.additionalSpeedRestrictions[0].restrictionFrom, DateTime.parse('2022-01-01T00:00:00Z'));
    expect(journey.metadata.additionalSpeedRestrictions[0].restrictionUntil, DateTime.parse('2060-01-01T00:00:00Z'));
    expect(journey.metadata.additionalSpeedRestrictions[0].reason?.de, 'Schutz Personal');
  });

  test('Test additional speed restriction out of journey times are filtered correctly', () async {
    final journey = getJourney('T3', 1);
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(7)); // other two restrictions are out of journey times

    expect(journey.metadata.additionalSpeedRestrictions, hasLength(7));
  });

  test('Test additional speed restriction is parsed correctly over multiple segments', () async {
    final journey = getJourney('T2', 3);
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(2));
    expect(speedRestrictions[0].restrictions, hasLength(1));
    expect(speedRestrictions[0].restrictions[0].kmFrom, 64.2);
    expect(speedRestrictions[0].restrictions[0].kmTo, 47.2);
    expect(speedRestrictions[0].restrictions[0].orderFrom, 700);
    expect(speedRestrictions[0].restrictions[0].orderTo, 206800);
    expect(speedRestrictions[0].restrictions[0].speed, 60);
    expect(speedRestrictions[0].order, 700);
    expect(speedRestrictions[1].restrictions[0].kmFrom, 64.2);
    expect(speedRestrictions[1].restrictions[0].kmTo, 47.2);
    expect(speedRestrictions[1].restrictions[0].orderFrom, 700);
    expect(speedRestrictions[1].restrictions[0].orderTo, 206800);
    expect(speedRestrictions[1].restrictions[0].speed, 60);
    expect(speedRestrictions[1].order, 206800);

    expect(journey.metadata.additionalSpeedRestrictions, hasLength(1));
    expect(journey.metadata.additionalSpeedRestrictions[0].kmFrom, 64.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].kmTo, 47.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderFrom, 700);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderTo, 206800);
    expect(journey.metadata.additionalSpeedRestrictions[0].speed, 60);
  });

  test('Test additional speed restriction without a date', () async {
    final journey = getJourney('T2', 3);
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(2));
    expect(speedRestrictions[0].restrictions, hasLength(1));
    expect(speedRestrictions[0].restrictions[0].restrictionFrom, isNull);
    expect(speedRestrictions[0].restrictions[0].restrictionUntil, isNull);
    expect(speedRestrictions[0].order, 700);
    expect(speedRestrictions[1].restrictions, hasLength(1));
    expect(speedRestrictions[1].restrictions[0].restrictionFrom, isNull);
    expect(speedRestrictions[1].restrictions[0].restrictionUntil, isNull);
    expect(speedRestrictions[1].order, 206800);

    expect(journey.metadata.additionalSpeedRestrictions, hasLength(1));
    expect(journey.metadata.additionalSpeedRestrictions[0].restrictionFrom, isNull);
    expect(journey.metadata.additionalSpeedRestrictions[0].restrictionUntil, isNull);
  });

  test('Test complex additional speed restrictions are parsed correctly', () async {
    final journey = getJourney('T18', 3);
    final speedRestrictions = journey.data
        .where((it) => it.type == Datatype.additionalSpeedRestriction)
        .cast<AdditionalSpeedRestrictionData>()
        .toList();

    expect(journey.valid, true);
    expect(speedRestrictions, hasLength(4));

    void checkNormalASRRestriction(AdditionalSpeedRestrictionData data) {
      expect(data.restrictions[0].kmFrom, 64.2);
      expect(data.restrictions[0].kmTo, 26.1);
      expect(data.restrictions[0].orderFrom, 700);
      expect(data.restrictions[0].orderTo, 2100);
      expect(data.restrictions[0].speed, 80);
    }

    // start of normal ASR between Genève-Aéroport and Morges
    expect(speedRestrictions[0].restrictions, hasLength(1));
    checkNormalASRRestriction(speedRestrictions[0]);
    expect(speedRestrictions[0].kmFrom, 64.2);
    expect(speedRestrictions[0].kmTo, 26.1);
    expect(speedRestrictions[0].speed, 80);
    expect(speedRestrictions[0].order, 700);

    // end of normal ASR between Genève-Aéroport and Morges
    expect(speedRestrictions[1].restrictions, hasLength(1));
    checkNormalASRRestriction(speedRestrictions[1]);
    expect(speedRestrictions[1].kmFrom, 64.2);
    expect(speedRestrictions[1].kmTo, 26.1);
    expect(speedRestrictions[1].speed, 80);
    expect(speedRestrictions[1].order, 2100);

    void checkComplexASRRestrictions(AdditionalSpeedRestrictionData data) {
      expect(data.restrictions[0].kmFrom, 83.1);
      expect(data.restrictions[0].kmTo, 6.6);
      expect(data.restrictions[0].orderFrom, 105600);
      expect(data.restrictions[0].orderTo, 210200);
      expect(data.restrictions[0].speed, 50);
      expect(data.restrictions[1].kmFrom, 47.2);
      expect(data.restrictions[1].kmTo, 12.0);
      expect(data.restrictions[1].orderFrom, 206800);
      expect(data.restrictions[1].orderTo, 209100);
      expect(data.restrictions[1].speed, 60);
    }

    // start of complex ASR between Lengnau and Zurich Flughafen
    expect(speedRestrictions[2].restrictions, hasLength(2));
    checkComplexASRRestrictions(speedRestrictions[2]);
    expect(speedRestrictions[2].kmFrom, 83.1);
    expect(speedRestrictions[2].kmTo, 6.6);
    expect(speedRestrictions[2].speed, 50);
    expect(speedRestrictions[2].order, 105600);

    // end of complex ASR between Lengnau and Zurich Flughafen
    expect(speedRestrictions[3].restrictions, hasLength(2));
    checkComplexASRRestrictions(speedRestrictions[3]);
    expect(speedRestrictions[3].kmFrom, 83.1);
    expect(speedRestrictions[3].kmTo, 6.6);
    expect(speedRestrictions[3].speed, 50);
    expect(speedRestrictions[3].order, 210200);

    // metadata should contain all restriction even if multiple are combined
    expect(journey.metadata.additionalSpeedRestrictions, hasLength(3));
    expect(journey.metadata.additionalSpeedRestrictions[0].kmFrom, 64.2);
    expect(journey.metadata.additionalSpeedRestrictions[0].kmTo, 26.1);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderFrom, 700);
    expect(journey.metadata.additionalSpeedRestrictions[0].orderTo, 2100);
    expect(journey.metadata.additionalSpeedRestrictions[0].speed, 80);
    expect(journey.metadata.additionalSpeedRestrictions[1].kmFrom, 47.2);
    expect(journey.metadata.additionalSpeedRestrictions[1].kmTo, 12.0);
    expect(journey.metadata.additionalSpeedRestrictions[1].orderFrom, 206800);
    expect(journey.metadata.additionalSpeedRestrictions[1].orderTo, 209100);
    expect(journey.metadata.additionalSpeedRestrictions[1].speed, 60);
    expect(journey.metadata.additionalSpeedRestrictions[2].kmFrom, 83.1);
    expect(journey.metadata.additionalSpeedRestrictions[2].kmTo, 6.6);
    expect(journey.metadata.additionalSpeedRestrictions[2].orderFrom, 105600);
    expect(journey.metadata.additionalSpeedRestrictions[2].orderTo, 210200);
    expect(journey.metadata.additionalSpeedRestrictions[2].speed, 50);
  });

  test('Test speed change is parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    final speedChanges = journey.data.where((it) => it.type == Datatype.speedChange).cast<SpeedChange>().toList();

    expect(journey.valid, true);
    expect(speedChanges, hasLength(2));
    expect(speedChanges[0].text, 'Zahnstangen Anfang');
    expect(speedChanges[0].speeds!, hasLength(2));
    _checkTrainSeriesSpeed<SingleSpeed>(
      speedChanges[0].speeds![0],
      expected: '55',
      trainSeries: TrainSeries.R,
      reduced: true,
      breakSeries: 100,
    );
    _checkTrainSeriesSpeed<SingleSpeed>(
      speedChanges[0].speeds![1],
      expected: '50',
      trainSeries: TrainSeries.A,
      reduced: false,
      breakSeries: 30,
    );
    expect(speedChanges[1].text, 'Zahnstangen Ende');
    expect(speedChanges[1].speeds!, hasLength(2));
    _checkTrainSeriesSpeed<SingleSpeed>(
      speedChanges[1].speeds![0],
      expected: '80',
      trainSeries: TrainSeries.R,
      reduced: false,
      breakSeries: 100,
    );
    _checkTrainSeriesSpeed<SingleSpeed>(
      speedChanges[1].speeds![1],
      expected: '80',
      trainSeries: TrainSeries.A,
      reduced: false,
      breakSeries: 30,
    );
  });

  test('Test connection tracks are parsed correctly', () async {
    final journey = getJourney('T9999', 5);
    final connectionTracks = journey.data
        .where((it) => it.type == Datatype.connectionTrack)
        .cast<ConnectionTrack>()
        .toList();

    expect(journey.valid, true);
    expect(connectionTracks, hasLength(3));
    expect(connectionTracks[0].text, isNull);
    expect(connectionTracks[0].speeds, isNull);
    expect(connectionTracks[1].text, 'AnG. WITZ');
    expect(connectionTracks[1].speeds, isNull);
    expect(connectionTracks[2].text, '22-6 Uhr');
    expect(connectionTracks[2].speeds, isNotNull);
    expect(connectionTracks[2].speeds!, hasLength(2));
    _checkTrainSeriesSpeed<SingleSpeed>(
      connectionTracks[2].speeds![0],
      expected: '45',
      trainSeries: TrainSeries.R,
      reduced: false,
      breakSeries: null,
    );
    _checkTrainSeriesSpeed<SingleSpeed>(
      connectionTracks[2].speeds![1],
      expected: '40',
      trainSeries: TrainSeries.A,
      reduced: false,
      breakSeries: null,
    );
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
    expect(journey.metadata.availableBreakSeries, hasLength(17));
    expect(journey.metadata.availableBreakSeries.elementAt(0).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(0).breakSeries, 105);
    expect(journey.metadata.availableBreakSeries.elementAt(5).trainSeries, TrainSeries.A);
    expect(journey.metadata.availableBreakSeries.elementAt(5).breakSeries, 50);
    expect(journey.metadata.availableBreakSeries.elementAt(15).trainSeries, TrainSeries.D);
    expect(journey.metadata.availableBreakSeries.elementAt(15).breakSeries, 30);
    expect(journey.metadata.availableBreakSeries.elementAt(16).trainSeries, TrainSeries.N);
    expect(journey.metadata.availableBreakSeries.elementAt(16).breakSeries, 30);

    journey = getJourney('T8', 1);
    expect(journey.valid, true);
    expect(journey.metadata.availableBreakSeries, hasLength(5));
    expect(journey.metadata.availableBreakSeries.elementAt(0).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(0).breakSeries, 115);
    expect(journey.metadata.availableBreakSeries.elementAt(1).trainSeries, TrainSeries.N);
    expect(journey.metadata.availableBreakSeries.elementAt(1).breakSeries, 50);
    expect(journey.metadata.availableBreakSeries.elementAt(2).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(2).breakSeries, 150);
    expect(journey.metadata.availableBreakSeries.elementAt(3).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(3).breakSeries, 60);
    expect(journey.metadata.availableBreakSeries.elementAt(4).trainSeries, TrainSeries.A);
    expect(journey.metadata.availableBreakSeries.elementAt(4).breakSeries, 70);
  });

  test('Test station/curve speeds are parsed correctly', () async {
    final journey = getJourney('T5', 1);
    expect(journey.valid, true);

    final curvePoints = journey.data.where((it) => it.type == Datatype.curvePoint).cast<CurvePoint>().toList();
    expect(curvePoints, hasLength(3));
    expect(curvePoints[0].localSpeeds, isNotNull);
    expect(curvePoints[0].localSpeeds, hasLength(4));
    expect(curvePoints[1].localSpeeds, isNotNull);
    expect(curvePoints[1].localSpeeds, hasLength(3));
    expect(curvePoints[2].localSpeeds, isNull);

    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();
    expect(servicePoints, hasLength(3));
    expect(servicePoints[0].speeds, isNotNull);
    expect(servicePoints[0].speeds, hasLength(17));
    expect(servicePoints[1].speeds, isNotNull);
    expect(servicePoints[1].speeds, hasLength(7));
    expect(servicePoints[2].speeds, isNotNull);
    expect(servicePoints[2].speeds, hasLength(17));
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
    expect(servicePoints, hasLength(7));

    // check ServicePoint Bern

    expect(servicePoints[0].localSpeeds, isNotNull);
    final localSpeed0 = servicePoints[0].localSpeeds!;
    expect(localSpeed0, hasLength(4));

    final rSpeedEntry1 = localSpeed0.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry1, isNotNull);
    _checkTrainSeriesSpeed<GraduatedSpeed>(rSpeedEntry1!, expected: '75-70-60', trainSeries: TrainSeries.R);

    final oSpeedEntry1 = localSpeed0.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry1, isNotNull);
    _checkTrainSeriesSpeed<GraduatedSpeed>(oSpeedEntry1!, expected: '75-70-60', trainSeries: TrainSeries.O);

    final sSpeedEntry1 = localSpeed0.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.S);
    expect(sSpeedEntry1, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(sSpeedEntry1!, expected: '70-60/50', trainSeries: TrainSeries.S);

    final nSpeedEntry1 = localSpeed0.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry1, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(nSpeedEntry1!, expected: '70/60', trainSeries: TrainSeries.N);

    // check ServicePoint Wankdorf

    expect(servicePoints[1].localSpeeds, isNull);

    // check ServicePoint Burgdorf

    final localSpeed1 = servicePoints[2].localSpeeds!;
    expect(localSpeed1, hasLength(7));

    final rSpeedEntry2 = localSpeed1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry2, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(
      rSpeedEntry2!,
      expected: '75-{70}/[60]',
      trainSeries: TrainSeries.R,
      breakSeries: 115,
    );

    final oSpeedEntry2 = localSpeed1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry2, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(oSpeedEntry2!, expected: '75-{70}/[60]', trainSeries: TrainSeries.O);

    final aSpeedEntry2 = localSpeed1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(aSpeedEntry2, isNotNull);
    _checkTrainSeriesSpeed<SingleSpeed>(aSpeedEntry2!, expected: '70', trainSeries: TrainSeries.A);

    final dSpeedEntry2 = localSpeed1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.D);
    expect(dSpeedEntry2, isNotNull);
    _checkTrainSeriesSpeed<SingleSpeed>(dSpeedEntry2!, expected: '70', trainSeries: TrainSeries.D);

    final nSpeedEntry2 = localSpeed1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry2, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(nSpeedEntry2!, expected: '75-{XX}/[XX]', trainSeries: TrainSeries.N);

    // check ServicePoint Olten

    final localSpeed3 = servicePoints[3].localSpeeds!;
    expect(localSpeed3, hasLength(2));

    final nSpeedEntry3 = localSpeed3.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry3, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(nSpeedEntry3!, expected: '80/70-60', trainSeries: TrainSeries.N);

    final sSpeedEntry3 = localSpeed3.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.S);
    expect(sSpeedEntry3, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(sSpeedEntry3!, expected: '70-60/50', trainSeries: TrainSeries.S);

    // check ServicePoint Dulliken

    final localSpeed4 = servicePoints[4].localSpeeds!;
    expect(localSpeed4, hasLength(2));

    final rSpeedEntry4 = localSpeed4.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry4, isNotNull);
    _checkTrainSeriesSpeed<GraduatedSpeed>(rSpeedEntry4!, expected: '75-70-65', trainSeries: TrainSeries.R);

    final aSpeedEntry4 = localSpeed4.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(aSpeedEntry4, isNotNull);
    _checkTrainSeriesSpeed<SingleSpeed>(aSpeedEntry4!, expected: '70', trainSeries: TrainSeries.A);

    // check ServicePoint Lenzburg

    final localSpeed5 = servicePoints[5].localSpeeds!;
    expect(localSpeed5, hasLength(2));

    final rSpeedEntry5 = localSpeed5.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry5, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(rSpeedEntry5!, expected: '70-65/55', trainSeries: TrainSeries.R);

    final aSpeedEntry5 = localSpeed5.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(aSpeedEntry5, isNotNull);
    _checkTrainSeriesSpeed<SingleSpeed>(aSpeedEntry5!, expected: '75', trainSeries: TrainSeries.A);

    // check ServicePoint Zuerich

    final localSpeed6 = servicePoints[6].localSpeeds!;
    expect(localSpeed6, hasLength(2));

    final rSpeedEntry6 = localSpeed6.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry6, isNotNull);
    _checkTrainSeriesSpeed<SingleSpeed>(rSpeedEntry6!, expected: '60', trainSeries: TrainSeries.R);

    final aSpeedEntry6 = localSpeed6.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(aSpeedEntry6, isNotNull);
    _checkTrainSeriesSpeed<SingleSpeed>(aSpeedEntry6!, expected: '60', trainSeries: TrainSeries.A);
  });

  test('Test graduated station speeds are parsed correctly', () async {
    final journey = getJourney('T8', 1);
    expect(journey.valid, true);

    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();
    expect(servicePoints, hasLength(7));

    // check ServicePoint Bern

    expect(servicePoints[0].graduatedSpeedInfo, isNotNull);
    final graduatedStationSpeeds1 = servicePoints[0].graduatedSpeedInfo!;
    expect(graduatedStationSpeeds1, hasLength(4));

    final rSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry1, isNotNull);
    _checkTrainSeriesSpeed<GraduatedSpeed>(
      rSpeedEntry1!,
      expected: '75-70-60',
      trainSeries: TrainSeries.R,
      text: 'Zusatzinformation A',
    );

    final oSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry1, isNotNull);
    _checkTrainSeriesSpeed<GraduatedSpeed>(
      oSpeedEntry1!,
      expected: '75-70-60',
      trainSeries: TrainSeries.O,
      text: 'Zusatzinformation A',
    );

    final sSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.S);
    expect(sSpeedEntry1, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(
      sSpeedEntry1!,
      expected: '70-60/50',
      trainSeries: TrainSeries.S,
      text: 'Zusatzinformation A',
    );

    final nSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry1, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(
      nSpeedEntry1!,
      expected: '70/60',
      trainSeries: TrainSeries.N,
      text: 'Zusatzinformation B',
    );

    final relevantSpeedInfo = servicePoints[0].relevantGraduatedSpeedInfo(
      BreakSeries(trainSeries: TrainSeries.N, breakSeries: 50),
    );
    expect(relevantSpeedInfo, hasLength(1));
    expect(relevantSpeedInfo[0].text, 'Zusatzinformation B');
    expect(relevantSpeedInfo[0].trainSeries, TrainSeries.N);

    // check ServicePoint Wankdorf

    expect(servicePoints[1].graduatedSpeedInfo, isNull);

    // check ServicePoint Burgdorf

    final graduatedStationSpeeds2 = servicePoints[2].graduatedSpeedInfo!;
    expect(graduatedStationSpeeds2, hasLength(3));

    final rSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry2, isNull);

    final oSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry2, isNull);

    final aSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(aSpeedEntry2, isNotNull);
    _checkTrainSeriesSpeed<SingleSpeed>(
      aSpeedEntry2!,
      expected: '70',
      trainSeries: TrainSeries.A,
      text: 'Zusatzinformation B',
    );

    final dSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.D);
    expect(dSpeedEntry2, isNotNull);
    _checkTrainSeriesSpeed<SingleSpeed>(
      dSpeedEntry2!,
      expected: '70',
      trainSeries: TrainSeries.D,
      text: 'Zusatzinformation B',
    );

    final nSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry2, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(
      nSpeedEntry2!,
      expected: '75-{XX}/[XX]',
      trainSeries: TrainSeries.N,
      text: 'Zusatzinformation C',
    );

    // check ServicePoint Olten

    final graduatedStationSpeeds3 = servicePoints[3].graduatedSpeedInfo!;
    expect(graduatedStationSpeeds3, hasLength(2));

    final nSpeedEntry3 = graduatedStationSpeeds3.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.N);
    expect(nSpeedEntry3, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(
      nSpeedEntry3!,
      expected: '80/70-60',
      trainSeries: TrainSeries.N,
      text: 'Zusatzinformation A',
    );

    final sSpeedEntry3 = graduatedStationSpeeds3.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.S);
    expect(sSpeedEntry3, isNotNull);
    _checkTrainSeriesSpeed<IncomingOutgoingSpeed>(
      sSpeedEntry3!,
      expected: '70-60/50',
      trainSeries: TrainSeries.S,
      text: 'Zusatzinformation A',
    );

    // check ServicePoint Dulliken

    final graduatedStationSpeeds4 = servicePoints[4].graduatedSpeedInfo!;
    expect(graduatedStationSpeeds4, hasLength(2));

    final rSpeedEntry3 = graduatedStationSpeeds4.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(rSpeedEntry3, isNotNull);
    _checkTrainSeriesSpeed<GraduatedSpeed>(
      rSpeedEntry3!,
      expected: '75-70-65',
      trainSeries: TrainSeries.R,
      text: 'Zusatzinformation D',
    );

    final oSpeedEntry3 = graduatedStationSpeeds4.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.O);
    expect(oSpeedEntry3, isNotNull);
    _checkTrainSeriesSpeed<GraduatedSpeed>(
      oSpeedEntry3!,
      expected: '75-70-65',
      trainSeries: TrainSeries.O,
      text: 'Zusatzinformation D',
    );
  });

  test('Test calculatedSpeed are parsed correctly for each service point', () async {
    final journey = getJourney('T23', 2);
    expect(journey.valid, true);

    final servicePoints = journey.data.whereType<ServicePoint>().toList();
    expect(servicePoints, hasLength(16));

    // service points without calculated speed
    final servicePointIdxWithoutCalculatedSpeed = {0, 1, 8, 10, 12, 13, 15};
    expect(
      servicePoints
          .whereIndexed((idx, _) => servicePointIdxWithoutCalculatedSpeed.contains(idx))
          .every((sP) => sP.calculatedSpeed == null),
      isTrue,
    );

    // service points with calculated speed
    expect(servicePoints[2].calculatedSpeed, isNotNull);
    expect(servicePoints[2].calculatedSpeed, equals(Speed.parse('110')));
    expect(servicePoints[3].calculatedSpeed, isNotNull);
    expect(servicePoints[3].calculatedSpeed, equals(Speed.parse('135')));
    expect(servicePoints[4].calculatedSpeed, isNotNull);
    expect(servicePoints[4].calculatedSpeed, equals(Speed.parse('0')));
    expect(servicePoints[5].calculatedSpeed, isNotNull);
    expect(servicePoints[5].calculatedSpeed, equals(Speed.parse('130')));
    expect(servicePoints[6].calculatedSpeed, isNotNull);
    expect(servicePoints[6].calculatedSpeed, equals(Speed.parse('0')));
    expect(servicePoints[7].calculatedSpeed, isNotNull);
    expect(servicePoints[7].calculatedSpeed, equals(Speed.parse('90')));
    expect(servicePoints[9].calculatedSpeed, isNotNull);
    expect(servicePoints[9].calculatedSpeed, equals(Speed.parse('130')));
    expect(servicePoints[11].calculatedSpeed, isNotNull);
    expect(servicePoints[11].calculatedSpeed, equals(Speed.parse('80')));
    expect(servicePoints[14].calculatedSpeed, isNotNull);
    expect(servicePoints[14].calculatedSpeed, equals(Speed.parse('0')));
  });

  test('Test advised speeds are parsed correctly', () async {
    final journey = getJourney('T24', 1);
    expect(journey.valid, isTrue);

    final advisedSpeeds = journey.metadata.advisedSpeedSegments.toList();
    expect(advisedSpeeds.length, 5);

    expect(advisedSpeeds[0], isA<FollowTrainAdvisedSpeedSegment>());
    expect(advisedSpeeds[0].speed, equals(SingleSpeed(value: '80')));
    expect(advisedSpeeds[0].startOrder, 500);
    expect(advisedSpeeds[0].endOrder, 2500);
    expect(advisedSpeeds[1], isA<FixedTimeAdvisedSpeedSegment>());
    expect(advisedSpeeds[1].speed, equals(SingleSpeed(value: '80')));
    expect(advisedSpeeds[1].startOrder, 4500);
    expect(advisedSpeeds[1].endOrder, 5000);
    expect(advisedSpeeds[2], isA<TrainFollowingAdvisedSpeedSegment>());
    expect(advisedSpeeds[2].speed, equals(SingleSpeed(value: '120')));
    expect(advisedSpeeds[2].startOrder, 5500);
    expect(advisedSpeeds[2].endOrder, 6500);
    expect(advisedSpeeds[3], isA<VelocityMaxAdvisedSpeedSegment>());
    expect(advisedSpeeds[3].speed, isNull);
    expect(advisedSpeeds[3].startOrder, 7000);
    expect(advisedSpeeds[3].endOrder, 7500);
    expect(advisedSpeeds[4], isA<VelocityMaxAdvisedSpeedSegment>());
    expect(advisedSpeeds[4].speed, isNull);
    expect(advisedSpeeds[4].startOrder, 8000);
    expect(advisedSpeeds[4].endOrder, 12000);
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
    final journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 1000);
    expect(journey.valid, true);
    expect(journey.metadata.lastServicePoint, journey.data.whereType<ServicePoint>().toList()[0]);
  });

  test('Test last service point is calculated correctly when second sp is driven over', () async {
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

  test('Test last service point is calculated correctly when is last service point of journey', () async {
    final journey = getJourney('T9', 1, tcCount: 1, relatedTrainInfoEventId: 5000);
    expect(journey.valid, true);
    expect(journey.metadata.lastServicePoint, journey.data.whereType<ServicePoint>().toList()[2]);
  });

  test('Test CommunicationNetworks parsed correctly', () async {
    final journey = getJourney('T12', 4);
    expect(journey.valid, true);

    final networkChanges = journey.metadata.communicationNetworkChanges;
    expect(networkChanges, hasLength(8));
    expect(networkChanges[0].order, 1000);
    expect(networkChanges[0].type, CommunicationNetworkType.gsmP);
    expect(networkChanges[1].order, 1500);
    expect(networkChanges[1].type, CommunicationNetworkType.sim);
    expect(networkChanges[2].order, 2000);
    expect(networkChanges[2].type, CommunicationNetworkType.gsmR);
    expect(networkChanges[3].order, 100100);
    expect(networkChanges[3].type, CommunicationNetworkType.gsmP);
    expect(networkChanges[4].order, 100500);
    expect(networkChanges[4].type, CommunicationNetworkType.sim);
    expect(networkChanges[5].order, 200300);
    expect(networkChanges[5].type, CommunicationNetworkType.sim);
    expect(networkChanges[6].order, 300100);
    expect(networkChanges[6].type, CommunicationNetworkType.sim);
    expect(networkChanges[7].order, 300500);
    expect(networkChanges[7].type, CommunicationNetworkType.gsmR);
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
    expect(
      opFootNotes[1].footNote.text,
      'Das ist <b>fett <i>und kursiv</i></b> <br/>und das ist <br/><i>noch kursiv</i>.',
    );
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

  test('Test operational indications parsed correctly', () async {
    final journey = getJourney('T22', 4);
    expect(journey.valid, true);

    final uncodedOperationalIndications = journey.data.whereType<UncodedOperationalIndication>().toList();
    expect(uncodedOperationalIndications, hasLength(3));

    expect(uncodedOperationalIndications[0].order, 0);
    expect(uncodedOperationalIndications[0].texts, hasLength(1));
    expect(uncodedOperationalIndications[0].texts[0], 'Renens VD: Halt an Halteort 3');
    expect(uncodedOperationalIndications[1].order, 100000);
    expect(uncodedOperationalIndications[1].texts, hasLength(2));
    expect(uncodedOperationalIndications[1].texts, contains('Lausanne: Halt an Halteort 2'));
    expect(
      uncodedOperationalIndications[1].texts,
      contains(
        'Strecke INN - MR: Bahnübergangsanlagen ohne Balisenüberwachung<br/>Straba. = Strassenbahnbereich<br/>E Straba. = Ende Strassenbahnbanbereich<br/>K Ende = Kurvenende<br/>F Fake = FakingIt',
      ),
    );
    expect(uncodedOperationalIndications[2].order, 200000);
    expect(uncodedOperationalIndications[2].texts, hasLength(1));
    expect(
      uncodedOperationalIndications[2].texts[0],
      contains(
        'Pully: Vorziehen bis Ende Perron. Das ist ein sehr langer einzeiliger Text um zu prüfen, ob die Anzeige korrekt damit umgehen kann.',
      ),
    );
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
    final journey = getJourney('T12', 4);
    expect(journey.valid, true);

    final radioContactLists = journey.metadata.radioContactLists.toList();

    expect(radioContactLists.length, 8);
    expect(radioContactLists[0].mainContacts.length, 1);
    expect(radioContactLists[0].mainContacts.first.contactIdentifier, '1407');
    expect(radioContactLists[1].mainContacts.length, 3);
    expect(radioContactLists[1].mainContacts.first.contactIdentifier, '1608');
    expect(radioContactLists[2].mainContacts.length, 1);
    expect(radioContactLists[2].selectiveContacts.length, 3);
    expect(radioContactLists[2].selectiveContacts.first.contactIdentifier, '1103');
    expect(radioContactLists[2].selectiveContacts.first.contactRole, 'Richtung Süd: Fahrdienstleiter');
    expect(radioContactLists[3].mainContacts.length, 1);
    expect(radioContactLists[3].mainContacts.first.contactIdentifier, '1407');
    expect(radioContactLists[4].mainContacts.length, 1);
    expect(radioContactLists[4].selectiveContacts.length, 3);
    expect(radioContactLists[4].selectiveContacts.first.contactIdentifier, '1103');
    expect(radioContactLists[4].selectiveContacts.first.contactRole, 'Richtung Süd: Fahrdienstleiter');
    expect(radioContactLists[5].mainContacts.length, 1);
    expect(radioContactLists[5].selectiveContacts.length, 3);
    expect(radioContactLists[5].selectiveContacts.first.contactIdentifier, '1103');
    expect(radioContactLists[5].selectiveContacts.first.contactRole, 'Richtung Süd: Fahrdienstleiter');
    expect(radioContactLists[6].mainContacts.length, 1);
    expect(radioContactLists[6].selectiveContacts.length, 3);
    expect(radioContactLists[6].selectiveContacts.first.contactIdentifier, '1103');
    expect(radioContactLists[6].selectiveContacts.first.contactRole, 'Richtung Süd: Fahrdienstleiter');
    expect(radioContactLists[7].mainContacts.length, 1);
    expect(radioContactLists[7].mainContacts.first.contactIdentifier, '1407');
  });

  test('Test SIM ContactList T20 parsed correctly', () async {
    final journey = getJourney('T20', 1);
    expect(journey.valid, true);

    final radioContactLists = journey.metadata.radioContactLists.toList();

    expect(radioContactLists.length, 9);
    expect(radioContactLists[0].mainContacts.length, 1);
    expect(radioContactLists[0].mainContacts.first.contactIdentifier, '1305');
    expect(radioContactLists[0].isSimCorridor, false);
    expect(radioContactLists[1].selectiveContacts.length, 1);
    expect(radioContactLists[1].selectiveContacts.first.contactIdentifier, '1390');
    expect(radioContactLists[1].selectiveContacts.first.contactRole, 'Frutigen - Kandergrund');
    expect(radioContactLists[1].isSimCorridor, true);
    expect(radioContactLists[2].isSimCorridor, false);
    expect(radioContactLists[3].isSimCorridor, false);
    expect(radioContactLists[4].isSimCorridor, false);
    expect(radioContactLists[5].isSimCorridor, true);
    expect(radioContactLists[6].isSimCorridor, false);
    expect(radioContactLists[7].isSimCorridor, true);
    expect(radioContactLists[8].isSimCorridor, false);
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

  test('Test stations signs are parsed correctly', () {
    final journey = getJourney('T21', 1);
    expect(journey.valid, true);

    final servicePoints = journey.data.whereType<ServicePoint>().toList();

    expect(servicePoints, hasLength(8));
    expect(servicePoints[0].stationSign1, StationSign.noExitSignal);
    expect(servicePoints[0].stationSign2, isNull);
    expect(servicePoints[1].stationSign1, StationSign.noEntrySignal);
    expect(servicePoints[1].stationSign2, StationSign.entryStationWithoutRailFreeAccess);
    expect(servicePoints[2].stationSign1, StationSign.deadendStation);
    expect(servicePoints[2].stationSign2, StationSign.noEntryExitSignal);
    expect(servicePoints[3].stationSign1, StationSign.openLevelCrossingBeforeExitSignal);
    expect(servicePoints[3].stationSign2, isNull);
    expect(servicePoints[4].stationSign1, StationSign.openLevelCrossingBeforeExitSignal);
    expect(servicePoints[4].stationSign2, isNull);
    expect(servicePoints[5].stationSign1, isNull);
    expect(servicePoints[5].stationSign2, isNull);
    expect(servicePoints[6].stationSign1, isNull);
    expect(servicePoints[6].stationSign2, isNull);
    expect(servicePoints[7].stationSign1, isNull);
    expect(servicePoints[7].stationSign2, isNull);
  });

  test('Test stations properties are parsed correctly', () {
    final journey = getJourney('T21', 1);
    expect(journey.valid, true);

    final servicePoints = journey.data.whereType<ServicePoint>().toList();

    // Geneve-Aeroport
    expect(servicePoints, hasLength(8));
    expect(servicePoints[0].properties, hasLength(1));
    expect(servicePoints[0].properties[0].sign, StationSign.deadendStation);
    expect(servicePoints[0].properties[0].text, '<b>A');
    expect(servicePoints[0].properties[0].speeds, hasLength(1));
    expect(servicePoints[0].properties[0].speeds![0].speed, isA<SingleSpeed>());
    expect((servicePoints[0].properties[0].speeds![0].speed as SingleSpeed).value, '55');
    expect((servicePoints[0].properties[0].speeds![0].speed as SingleSpeed).isSquared, true);
    expect((servicePoints[0].properties[0].speeds![0].speed as SingleSpeed).isCircled, false);

    // Nyon
    expect(servicePoints[2].properties, hasLength(1));
    expect(servicePoints[2].properties[0].sign, isNull);
    expect(servicePoints[2].properties[0].text, isNull);
    expect(servicePoints[2].properties[0].speeds, hasLength(17));
    final speed = servicePoints[2].properties[0].speeds.speedFor(TrainSeries.A, breakSeries: 50)!.speed;
    expect(speed, isA<IncomingOutgoingSpeed>());
    final incomingOutgoingSpeed = speed as IncomingOutgoingSpeed;
    expect((incomingOutgoingSpeed.incoming as SingleSpeed).value, '60');
    expect((incomingOutgoingSpeed.incoming as SingleSpeed).isSquared, true);
    expect((incomingOutgoingSpeed.incoming as SingleSpeed).isCircled, false);
    expect((incomingOutgoingSpeed.outgoing as SingleSpeed).value, '70');
    expect((incomingOutgoingSpeed.outgoing as SingleSpeed).isCircled, true);
    expect((incomingOutgoingSpeed.outgoing as SingleSpeed).isSquared, false);

    // Vevey
    expect(servicePoints[5].properties, hasLength(3));
    expect(servicePoints[5].properties[0].sign, isNull);
    expect(servicePoints[5].properties[0].text, '<i>via Stammlinie');
    expect(servicePoints[5].properties[0].speeds, isNull);
    expect(servicePoints[5].properties[1].sign, isNull);
    expect(servicePoints[5].properties[1].text, isNull);
    expect(servicePoints[5].properties[1].speeds, isNotNull);
    expect(servicePoints[5].properties[1].speeds![0].reduced, true);
    expect(servicePoints[5].properties[1].speeds![0].speed, isA<SingleSpeed>());
    expect((servicePoints[5].properties[1].speeds![0].speed as SingleSpeed).value, '35');
    expect((servicePoints[5].properties[1].speeds![0].speed as SingleSpeed).isSquared, false);
    expect((servicePoints[5].properties[1].speeds![0].speed as SingleSpeed).isCircled, false);
    expect(servicePoints[5].properties[2].sign, StationSign.deadendStation);
    expect(servicePoints[5].properties[2].text, '<b>A');
    expect(servicePoints[5].properties[2].speeds, isNull);

    // Aigle
    expect(servicePoints[7].properties, hasLength(1));
    expect(servicePoints[7].properties[0].sign, StationSign.entryOccupiedTrack);
    expect(servicePoints[7].properties[0].text, isNull);
    expect(servicePoints[7].properties[0].speeds, isNull);
  });

  test('Test properties for break series', () {
    final journey = getJourney('T21', 1);
    expect(journey.valid, true);

    final servicePoints = journey.data.whereType<ServicePoint>().toList();

    // Geneve-Aeroport
    expect(servicePoints[0].propertiesFor(BreakSeries(trainSeries: TrainSeries.A, breakSeries: 50)), hasLength(1));
    expect(servicePoints[0].propertiesFor(BreakSeries(trainSeries: TrainSeries.A, breakSeries: 60)), hasLength(0));
    expect(
      servicePoints[0].propertiesFor(BreakSeries(trainSeries: TrainSeries.R, breakSeries: 115)),
      hasLength(0),
    );

    // Vevey
    expect(servicePoints[5].propertiesFor(BreakSeries(trainSeries: TrainSeries.A, breakSeries: 50)), hasLength(3));
    expect(servicePoints[5].propertiesFor(BreakSeries(trainSeries: TrainSeries.A, breakSeries: 60)), hasLength(3));
    expect(
      servicePoints[5].propertiesFor(BreakSeries(trainSeries: TrainSeries.R, breakSeries: 115)),
      hasLength(2),
    );
  });
}

void _checkTrainSeriesSpeed<T extends Speed>(
  TrainSeriesSpeed actual, {
  required String expected,
  required TrainSeries trainSeries,
  int? breakSeries,
  bool? reduced,
  String? text,
}) {
  expect(actual.speed, isA<T>());
  expect(actual.speed, equals(Speed.parse(expected)));

  expect(trainSeries, equals(actual.trainSeries));
  expect(actual.breakSeries, equals(breakSeries));
  expect(actual.text, equals(text));
  if (reduced != null) expect(actual.reduced, equals(reduced));
}
