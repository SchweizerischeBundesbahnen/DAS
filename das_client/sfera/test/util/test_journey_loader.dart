import 'dart:io';

import 'package:collection/collection.dart';
import 'package:sfera/component.dart';
import 'package:sfera/src/data/dto/g2b_event_payload_dto.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';

import 'test_journey.dart';
import 'test_journey_skeleton.dart';

/// Uses [SferaReplyParser] and [SferaModelMapper] to parse journeys from static resources in directories
/// to a [TestJourney] with JOURNEY_NAME as name field.
///
/// Expected dir layout of a static resource journey:
/// ```
/// test_journey
/// │   SFERA_JP_JOURNEY_NAME.xml
/// │   SFERA_SP_JOURNEY_NAME_*.xml (m times)
/// │   SFERA_TC_JOURNEY_NAME_*.xml
/// │   SFERA_Event_JOURNEY_NAME_*.xml (n times)
/// ```
///
/// Will consider all subdirs containing exactly one SFERA_JP_*, at least one SFERA_SP_*
/// and at least one SFERA_TC_* file.
///
/// In case there are event files with JP updates, will create multiple journeys, one for each JP update event.
class TestJourneyLoader {
  static const _sferaStaticResourcesDirPath = '../../sfera_mock/src/main/resources/static_sfera_resources';
  static const _clientTestResourcesDirPath = './test_resources';

  static Directory get _clientTestResourcesDir => Directory(_clientTestResourcesDirPath);

  static Directory get _sferaStaticResourcesDir => Directory(_sferaStaticResourcesDirPath);

  static Iterable<TestJourney> fromStaticSferaResources() => fromRootDir(_sferaStaticResourcesDir);

  static Iterable<TestJourney> fromClientTestResources() => fromRootDir(_clientTestResourcesDir);

  /// Loads journeys ignoring train characteristics and limiting the number of segment profiles considered.
  ///
  /// In case the count is lower than the given segment profiles in the test dir, this will lead to an invalid journey.
  static TestJourney partialJourney(String journeyName, {int? maxSpCount}) {
    final journeyDir = _getTestDirWithJourney(journeyName);
    if (journeyDir == null) throw Exception('No journey with $journeyName found!');

    TestJourneySkeleton journeySkeleton = _parseTestJourneyFilesToSkeleton(journeyDir)!;

    journeySkeleton = journeySkeleton.withoutTrainCharacteristics();

    if (maxSpCount != null) journeySkeleton = journeySkeleton.limitedNumberOfSegmentProfiles(maxSpCount);
    return _skeletonToTestJourneys(journeySkeleton).first;
  }

  static Iterable<TestJourney> fromRootDir(Directory rootDir) sync* {
    final subdirs = rootDir.listSync(recursive: true).whereType<Directory>();

    for (final dir in subdirs) {
      final testJourneySkeleton = _parseTestJourneyFilesToSkeleton(dir);
      if (testJourneySkeleton == null) continue;

      yield* _skeletonToTestJourneys(testJourneySkeleton);
    }
    return;
  }

  static TestJourneySkeleton? _parseTestJourneyFilesToSkeleton(Directory dir) {
    final files = dir.listSync().whereType<File>();

    final List<File> jpFiles = files.where((f) => f.path.contains('SFERA_JP_')).toList();
    // TODO: https://github.com/SchweizerischeBundesbahnen/DAS/issues/1390
    // Take out the sorting and see what happens.
    final List<File> spFiles = files.where((f) => f.path.contains('SFERA_SP_')).sortedBy((f) => f.path);
    final List<File> tcFiles = files.where((f) => f.path.contains('SFERA_TC_')).toList();
    final eventFiles = files.where((f) => f.path.contains('SFERA_Event_')).toList();

    if (jpFiles.isEmpty || spFiles.isEmpty || jpFiles.length > 1) return null;

    final journeyName = _getJourneyName(jpFiles.first);
    if (journeyName == null) return null;

    final baseJourneyProfile = SferaReplyParser.parse<JourneyProfileDto>(jpFiles.first.readAsStringSync());

    final segmentProfiles = spFiles
        .map((f) => SferaReplyParser.parse<SegmentProfileDto>(f.readAsStringSync()))
        .toList();

    final trainCharacteristics = tcFiles
        .map((f) => SferaReplyParser.parse<TrainCharacteristicsDto>(f.readAsStringSync()))
        .toList();

    final List<TestJourneyEvent> testEvents = [];
    for (final file in eventFiles) {
      final nameRegEx = RegExp('(?<=SFERA_Event_${journeyName}_).*(?=.xml)');
      final eventName = nameRegEx.firstMatch(file.path)?[0];
      if (eventName == null) continue;

      final event = SferaReplyParser.parse<G2bEventPayloadDto>(file.readAsStringSync());

      testEvents.add(TestJourneyEvent(name: eventName, payload: event));
    }

    return TestJourneySkeleton(
      journeyName: journeyName,
      journeyProfile: baseJourneyProfile,
      segmentProfiles: segmentProfiles,
      trainCharacteristics: trainCharacteristics,
      journeyEvents: testEvents,
    );
  }

  static String? _getJourneyName(File jpFile) {
    final nameRegEx = RegExp('(?<=SFERA_JP_).*(?=.xml)');
    return nameRegEx.firstMatch(jpFile.path)?[0];
  }

  static Iterable<TestJourney> _skeletonToTestJourneys(TestJourneySkeleton testJourneySkeleton) sync* {
    final journey = SferaModelMapper.mapToJourney(
      journeyProfile: testJourneySkeleton.journeyProfile,
      segmentProfiles: testJourneySkeleton.segmentProfiles,
      trainCharacteristics: testJourneySkeleton.trainCharacteristics,
    );
    yield TestJourney(journey: journey, name: testJourneySkeleton.journeyName);

    for (final event in testJourneySkeleton.journeyEvents) {
      final eventJourneyProfile = event.payload.journeyProfiles.firstOrNull;
      final relatedTrainInformation = event.payload.relatedTrainInformation;

      if (eventJourneyProfile != null) {
        final journey = SferaModelMapper.mapToJourney(
          journeyProfile: eventJourneyProfile,
          segmentProfiles: testJourneySkeleton.segmentProfiles,
          trainCharacteristics: testJourneySkeleton.trainCharacteristics,
          relatedTrainInformation: relatedTrainInformation,
        );
        yield TestJourney(journey: journey, name: testJourneySkeleton.journeyName, eventName: event.name);
      }

      if (relatedTrainInformation != null && eventJourneyProfile == null) {
        final journey = SferaModelMapper.mapToJourney(
          journeyProfile: testJourneySkeleton.journeyProfile,
          segmentProfiles: testJourneySkeleton.segmentProfiles,
          trainCharacteristics: testJourneySkeleton.trainCharacteristics,
          relatedTrainInformation: relatedTrainInformation,
        );
        yield TestJourney(journey: journey, name: testJourneySkeleton.journeyName, eventName: event.name);
      }
    }
    return;
  }

  static Directory? _getTestDirWithJourney(String journeyName) {
    final filter = RegExp('SFERA_JP_$journeyName(?=.xml)');
    return _clientTestResourcesDir
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => filter.hasMatch(f.path))
        .firstOrNull
        ?.parent;
  }
}

extension _TestJourneySkeletonX on TestJourneySkeleton {
  TestJourneySkeleton withoutTrainCharacteristics() => TestJourneySkeleton(
    journeyName: journeyName,
    journeyProfile: journeyProfile,
    segmentProfiles: List.from(segmentProfiles),
    trainCharacteristics: const [],
    journeyEvents: List.from(journeyEvents),
  );

  TestJourneySkeleton limitedNumberOfSegmentProfiles(int maxSpCount) => TestJourneySkeleton(
    journeyName: journeyName,
    journeyProfile: journeyProfile,
    segmentProfiles: segmentProfiles.take(maxSpCount).toList(),
    trainCharacteristics: List.from(trainCharacteristics),
    journeyEvents: List.from(journeyEvents),
  );
}
