import 'dart:io';

import 'package:collection/collection.dart';
import 'package:das_client/model/journey/additional_speed_restriction_data.dart';
import 'package:das_client/model/journey/balise.dart';
import 'package:das_client/model/journey/cab_signaling.dart';
import 'package:das_client/model/journey/connection_track.dart';
import 'package:das_client/model/journey/curve_point.dart';
import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/level_crossing.dart';
import 'package:das_client/model/journey/protection_section.dart';
import 'package:das_client/model/journey/service_point.dart';
import 'package:das_client/model/journey/signal.dart';
import 'package:das_client/model/journey/speed.dart';
import 'package:das_client/model/journey/speed_change.dart';
import 'package:das_client/model/journey/track_equipment.dart';
import 'package:das_client/model/journey/train_series.dart';
import 'package:das_client/model/journey/tram_area.dart';
import 'package:das_client/model/journey/whistles.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/mapper/sfera_model_mapper.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter_test/flutter_test.dart';

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

  Journey getJourney(String trainNumber, int spCount,
      {String? spPostfix, String? jpPostfix, String? tcPostfix, int tcCount = 0}) {
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
    final journeyProfile = SferaReplyParser.parse<JourneyProfile>(journeyFile.readAsStringSync());
    expect(journeyProfile.validate(), true);

    final List<SegmentProfile> segmentProfiles = [];
    final baseSPFileName = 'SFERA_SP_$trainNumber${spPostfix != null ? '_$spPostfix' : ''}';
    for (final File file in getFilesForSp(testDirectory.path, baseSPFileName, spCount)) {
      final segmentProfile = SferaReplyParser.parse<SegmentProfile>(file.readAsStringSync());
      expect(segmentProfile.validate(), true);
      segmentProfiles.add(segmentProfile);
    }

    final List<TrainCharacteristics> trainCharacteristics = [];
    final baseTCFileName = 'SFERA_TC_$trainNumber${tcPostfix != null ? '_$tcPostfix' : ''}';
    for (final File file in getFilesForTc(testDirectory.path, baseTCFileName, tcCount)) {
      final trainCharacteristic = SferaReplyParser.parse<TrainCharacteristics>(file.readAsStringSync());
      expect(trainCharacteristic.validate(), true);
      trainCharacteristics.add(trainCharacteristic);
    }

    return SferaModelMapper.mapToJourney(journeyProfile, segmentProfiles, trainCharacteristics);
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
    expect(servicePoints[0].name.de, 'Bahnhof A');
    expect(servicePoints[1].name.de, 'Haltestelle B');
    expect(servicePoints[2].name.de, 'Halt auf Verlangen C');
    expect(servicePoints[3].name.de, 'Klammerbahnhof D');
    expect(servicePoints[4].name.de, 'Klammerbahnhof D1');
    expect(servicePoints[5].name.de, 'Bahnhof E');
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
    expect(journey.data[17].kilometre[0], 3.5);
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
    expect(journey.data[17].order, 300500);
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
    expect(journey.metadata.nonStandardTrackEquipmentSegments[0].endOrder, 1500);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[1].type,
        TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[1].startOrder, isNull);
    expect(journey.metadata.nonStandardTrackEquipmentSegments[1].endOrder, 102300);
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
    expect(servicePoints[0].bracketStation, isNull);
    expect(servicePoints[1].bracketStation, isNull);
    expect(servicePoints[2].bracketStation, isNull);
    expect(servicePoints[3].bracketStation, isNotNull);
    expect(servicePoints[3].bracketStation!.mainStationAbbreviation, isNull);
    expect(servicePoints[4].bracketStation, isNotNull);
    expect(servicePoints[4].bracketStation!.mainStationAbbreviation, 'D');
    expect(servicePoints[5].bracketStation, isNull);
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
    expect(speedChanges[0].speedData!.velocities, hasLength(2));
    expect(speedChanges[0].speedData!.velocities[0].trainSeries, TrainSeries.R);
    expect(speedChanges[0].speedData!.velocities[0].speed, '55');
    expect(speedChanges[0].speedData!.velocities[0].reduced, true);
    expect(speedChanges[0].speedData!.velocities[0].breakSeries, 100);
    expect(speedChanges[0].speedData!.velocities[1].trainSeries, TrainSeries.A);
    expect(speedChanges[0].speedData!.velocities[1].speed, '50');
    expect(speedChanges[0].speedData!.velocities[1].reduced, false);
    expect(speedChanges[0].speedData!.velocities[1].breakSeries, 30);
    expect(speedChanges[1].text, 'Zahnstangen Ende');
    expect(speedChanges[1].speedData!.velocities, hasLength(2));
    expect(speedChanges[1].speedData!.velocities[0].trainSeries, TrainSeries.R);
    expect(speedChanges[1].speedData!.velocities[0].speed, '80');
    expect(speedChanges[1].speedData!.velocities[0].reduced, false);
    expect(speedChanges[1].speedData!.velocities[0].breakSeries, 100);
    expect(speedChanges[1].speedData!.velocities[1].trainSeries, TrainSeries.A);
    expect(speedChanges[1].speedData!.velocities[1].speed, '80');
    expect(speedChanges[1].speedData!.velocities[1].reduced, false);
    expect(speedChanges[1].speedData!.velocities[1].breakSeries, 30);
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
    expect(connectionTracks[2].speedData!.velocities, hasLength(2));
    expect(connectionTracks[2].speedData!.velocities[0].trainSeries, TrainSeries.R);
    expect(connectionTracks[2].speedData!.velocities[0].speed, '45');
    expect(connectionTracks[2].speedData!.velocities[0].reduced, false);
    expect(connectionTracks[2].speedData!.velocities[0].breakSeries, isNull);
    expect(connectionTracks[2].speedData!.velocities[1].trainSeries, TrainSeries.A);
    expect(connectionTracks[2].speedData!.velocities[1].speed, '40');
    expect(connectionTracks[2].speedData!.velocities[1].reduced, false);
    expect(connectionTracks[2].speedData!.velocities[1].breakSeries, isNull);
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
    expect(journey.metadata.availableBreakSeries, hasLength(2));
    expect(journey.metadata.availableBreakSeries.elementAt(0).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(0).breakSeries, 115);
    expect(journey.metadata.availableBreakSeries.elementAt(1).trainSeries, TrainSeries.R);
    expect(journey.metadata.availableBreakSeries.elementAt(1).breakSeries, 150);
  });

  test('Test station/curve speeds are parsed correctly', () async {
    final journey = getJourney('T5', 1);
    expect(journey.valid, true);

    final curvePoints = journey.data.where((it) => it.type == Datatype.curvePoint).cast<CurvePoint>().toList();
    expect(curvePoints, hasLength(3));
    expect(curvePoints[0].speedData, isNotNull);
    expect(curvePoints[0].speedData!.velocities, hasLength(3));
    expect(curvePoints[1].speedData, isNotNull);
    expect(curvePoints[1].speedData!.velocities, hasLength(2));
    expect(curvePoints[2].speedData, isNull);

    final servicePoints = journey.data.where((it) => it.type == Datatype.servicePoint).cast<ServicePoint>().toList();
    expect(servicePoints, hasLength(3));
    expect(servicePoints[0].speedData, isNotNull);
    expect(servicePoints[0].speedData!.velocities, hasLength(16));
    expect(servicePoints[1].speedData, isNotNull);
    expect(servicePoints[1].speedData!.velocities, hasLength(6));
    expect(servicePoints[2].speedData, isNotNull);
    expect(servicePoints[2].speedData!.velocities, hasLength(16));
  });

  test('Test train characteristics break series is parsed correctly', () async {
    final journey = getJourney('T5', 1, tcCount: 1);
    expect(journey.valid, true);
    expect(journey.metadata.breakSeries, isNotNull);
    expect(journey.metadata.breakSeries!.trainSeries, TrainSeries.R);
    expect(journey.metadata.breakSeries!.breakSeries, 115);
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

    expect(servicePoints[0].stationSpeedData, isNotNull);
    final graduatedStationSpeeds1 = servicePoints[0].stationSpeedData!.graduatedSpeeds;
    expect(graduatedStationSpeeds1, hasLength(4));

    final roSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(roSpeedEntry1, isNotNull);
    expect(roSpeedEntry1!.text, isNull);
    expect(roSpeedEntry1.trainSeries, TrainSeries.R);
    expect(roSpeedEntry1.incomingSpeeds, hasLength(3));
    _checkSpeed(roSpeedEntry1.incomingSpeeds[0], 75);
    _checkSpeed(roSpeedEntry1.incomingSpeeds[1], 70);
    _checkSpeed(roSpeedEntry1.incomingSpeeds[2], 60);
    expect(roSpeedEntry1.outgoingSpeeds, isEmpty);

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

    expect(servicePoints[1].stationSpeedData, isNull);

    // check ServicePoint Burgdorf

    final graduatedStationSpeeds2 = servicePoints[2].stationSpeedData!.graduatedSpeeds;
    expect(graduatedStationSpeeds2, hasLength(4));

    final roSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(roSpeedEntry2, isNotNull);
    expect(roSpeedEntry2!.text, isNull);
    expect(roSpeedEntry2.trainSeries, TrainSeries.R);
    expect(roSpeedEntry2.incomingSpeeds, hasLength(2));
    _checkSpeed(roSpeedEntry2.incomingSpeeds[0], 75);
    _checkSpeed(roSpeedEntry2.incomingSpeeds[1], 70, isCircled: true);
    expect(roSpeedEntry2.outgoingSpeeds, hasLength(1));
    _checkSpeed(roSpeedEntry2.outgoingSpeeds[0], 60, isSquared: true);

    final adSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(adSpeedEntry2, isNotNull);
    expect(adSpeedEntry2!.text, isNull);
    expect(adSpeedEntry2.trainSeries, TrainSeries.A);
    expect(adSpeedEntry2.incomingSpeeds, hasLength(1));
    _checkSpeed(adSpeedEntry2.incomingSpeeds[0], 70);
    expect(adSpeedEntry2.outgoingSpeeds, isEmpty);

    // check ServicePoint Olten

    final graduatedStationSpeeds3 = servicePoints[3].stationSpeedData!.graduatedSpeeds;
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

    expect(servicePoints[0].graduatedSpeedData, isNotNull);
    final graduatedStationSpeeds1 = servicePoints[0].graduatedSpeedData!.graduatedSpeeds;
    expect(graduatedStationSpeeds1, hasLength(4));

    final roSpeedEntry1 = graduatedStationSpeeds1.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(roSpeedEntry1, isNotNull);
    expect(roSpeedEntry1!.text, 'Zusatzinformation A');
    expect(roSpeedEntry1.trainSeries, TrainSeries.R);
    expect(roSpeedEntry1.incomingSpeeds, hasLength(3));
    _checkSpeed(roSpeedEntry1.incomingSpeeds[0], 75);
    _checkSpeed(roSpeedEntry1.incomingSpeeds[1], 70);
    _checkSpeed(roSpeedEntry1.incomingSpeeds[2], 60);
    expect(roSpeedEntry1.outgoingSpeeds, isEmpty);

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

    // check ServicePoint Wankdorf

    expect(servicePoints[1].graduatedSpeedData, isNull);

    // check ServicePoint Burgdorf

    final graduatedStationSpeeds2 = servicePoints[2].graduatedSpeedData!.graduatedSpeeds;
    expect(graduatedStationSpeeds2, hasLength(4));

    final roSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.R);
    expect(roSpeedEntry2, isNotNull);
    expect(roSpeedEntry2!.text, 'Zusatzinformation A');
    expect(roSpeedEntry2.trainSeries, TrainSeries.R);
    expect(roSpeedEntry2.incomingSpeeds, hasLength(2));
    _checkSpeed(roSpeedEntry2.incomingSpeeds[0], 75);
    _checkSpeed(roSpeedEntry2.incomingSpeeds[1], 70, isCircled: true);
    expect(roSpeedEntry2.outgoingSpeeds, hasLength(1));
    _checkSpeed(roSpeedEntry2.outgoingSpeeds[0], 60, isSquared: true);

    final adSpeedEntry2 = graduatedStationSpeeds2.firstWhereOrNull((speeds) => speeds.trainSeries == TrainSeries.A);
    expect(adSpeedEntry2, isNotNull);
    expect(adSpeedEntry2!.text, 'Zusatzinformation B');
    expect(adSpeedEntry2.trainSeries, TrainSeries.A);
    expect(adSpeedEntry2.incomingSpeeds, hasLength(1));
    _checkSpeed(adSpeedEntry2.incomingSpeeds[0], 70);
    expect(adSpeedEntry2.outgoingSpeeds, isEmpty);

    // check ServicePoint Olten

    final graduatedStationSpeeds3 = servicePoints[3].graduatedSpeedData!.graduatedSpeeds;
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
}

void _checkSpeed(Speed speed, int speedValue, {bool isCircled = false, bool isSquared = false}) {
  expect(speed.speed, speedValue);
  expect(speed.isCircled, isCircled);
  expect(speed.isSquared, isSquared);
}
