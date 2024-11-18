import 'dart:io';

import 'package:das_client/model/journey/datatype.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/model/journey/service_point.dart';
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

  Journey getJourney(String trainNumber, int spCount) {
    final journeyFile = File('test_resources/jp/SFERA_JP_$trainNumber.xml');
    final journeyProfile = SferaReplyParser.parse<JourneyProfile>(journeyFile.readAsStringSync());
    expect(journeyProfile.validate(), true);
    final List<SegmentProfile> segmentProfiles = [];

    for (final File file in getFilesForSp('SFERA_SP_$trainNumber', spCount)) {
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

  test('Test kilometre are parsed correctly', () async {
    final journey = getJourney('9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(5));
    expect(journey.data[0].kilometre[0], 0.5);
    expect(journey.data[1].kilometre[0], 1.5);
    expect(journey.data[2].kilometre[0], 2.4);
    expect(journey.data[3].kilometre[0], 3.7);
    expect(journey.data[3].kilometre[1], 0);
    expect(journey.data[4].kilometre[0], 0.6);
  });

  test('Test order is generated correctly', () async {
    final journey = getJourney('9999', 5);

    expect(journey.valid, true);
    expect(journey.data, hasLength(5));
    expect(journey.data[0].order, 000500);
    expect(journey.data[1].order, 100500);
    expect(journey.data[2].order, 200400);
    expect(journey.data[3].order, 300700);
    expect(journey.data[4].order, 400300);
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
}
