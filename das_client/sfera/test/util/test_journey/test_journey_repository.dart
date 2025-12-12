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
class TestJourneyRepository {
  static const _sferaStaticResourcesDirPath = '../../sfera_mock/src/main/resources/static_sfera_resources';
  static const _clientTestResourcesDirPath = './test_resources';

  static Directory get _clientTestResourcesDir => Directory(_clientTestResourcesDirPath);

  static Directory get _sferaStaticResourcesDir => Directory(_sferaStaticResourcesDirPath);

  static Iterable<TestJourney> getAllUniqueJourneysByName() =>
      getFromStaticSferaResources().followedBy(getFromClientTestResources()).uniqueNames;

  static Iterable<TestJourney> getFromStaticSferaResources() => fromRootDir(_sferaStaticResourcesDir);

  static Iterable<TestJourney> getFromClientTestResources() => fromRootDir(_clientTestResourcesDir);

  /// Loads journeys ignoring train characteristics and limiting the number of segment profiles considered.
  ///
  /// In case the count is lower than the given segment profiles in the test dir, this will lead to an invalid journey.
  static TestJourney partialJourney(String journeyName, {int? maxSpCount}) {
    final journeyDir = _getTestDirWithJourney(journeyName);
    if (journeyDir == null) throw Exception('No journey with $journeyName found!');

    final journeySkeletons = _parseTestJourneyFilesToSkeletons(journeyDir).nonNulls;

    TestJourneySkeleton? baseSkeleton = journeySkeletons.firstWhereOrNull((skeleton) => skeleton.journeyEvent == null);
    if (baseSkeleton == null) throw Exception('No journey without events found for $journeyName');

    baseSkeleton = baseSkeleton.withoutTrainCharacteristics();

    if (maxSpCount != null) baseSkeleton = baseSkeleton.limitedNumberOfSegmentProfiles(maxSpCount);
    return baseSkeleton.toTestJourney();
  }

  static Iterable<TestJourney> fromRootDir(Directory rootDir) sync* {
    final subdirs = rootDir.listSync(recursive: true).whereType<Directory>();

    for (final dir in subdirs) {
      final testJourneySkeletons = _parseTestJourneyFilesToSkeletons(dir);

      yield* testJourneySkeletons.map((skeleton) => skeleton.toTestJourney());
    }
  }

  static Iterable<TestJourneySkeleton> _parseTestJourneyFilesToSkeletons(Directory dir) sync* {
    final files = dir.listSync().whereType<File>();

    final List<File> jpFiles = files.where((f) => f.path.contains('SFERA_JP_')).toList();
    // TODO: https://github.com/SchweizerischeBundesbahnen/DAS/issues/1390
    // Take out the sorting and see what happens.
    final List<File> spFiles = files.where((f) => f.path.contains('SFERA_SP_')).sortedBy((f) => f.path);
    final List<File> tcFiles = files.where((f) => f.path.contains('SFERA_TC_')).toList();
    final eventFiles = files.where((f) => f.path.contains('SFERA_Event_')).toList();

    if (jpFiles.isEmpty || spFiles.isEmpty || jpFiles.length > 1) return;

    final journeyName = _getJourneyName(jpFiles.first);
    if (journeyName == null) return;

    final baseJourneyProfile = SferaReplyParser.parse<JourneyProfileDto>(jpFiles.first.readAsStringSync());

    final segmentProfiles = spFiles
        .map((f) => SferaReplyParser.parse<SegmentProfileDto>(f.readAsStringSync()))
        .toList();

    final trainCharacteristics = tcFiles
        .map((f) => SferaReplyParser.parse<TrainCharacteristicsDto>(f.readAsStringSync()))
        .toList();

    yield TestJourneySkeleton(
      journeyName: journeyName,
      journeyProfile: baseJourneyProfile,
      segmentProfiles: segmentProfiles,
      trainCharacteristics: trainCharacteristics,
    );

    for (final file in eventFiles) {
      final nameRegEx = RegExp('(?<=SFERA_Event_${journeyName}_).*(?=.xml)');
      final eventName = nameRegEx.firstMatch(file.path)?[0];
      if (eventName == null) continue;

      final eventPayload = SferaReplyParser.parse<G2bEventPayloadDto>(file.readAsStringSync());

      JourneyProfileDto journeyProfile = baseJourneyProfile;
      if (eventPayload.journeyProfiles.isNotEmpty) journeyProfile = eventPayload.journeyProfiles.first;

      yield TestJourneySkeleton(
        journeyName: journeyName,
        journeyProfile: journeyProfile,
        segmentProfiles: segmentProfiles,
        trainCharacteristics: trainCharacteristics,
        journeyEvent: TestJourneyEvent(name: eventName, payload: eventPayload),
      );
    }
  }

  static String? _getJourneyName(File jpFile) {
    final nameRegEx = RegExp('(?<=SFERA_JP_).*(?=.xml)');
    return nameRegEx.firstMatch(jpFile.path)?[0];
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
    segmentProfiles: segmentProfiles,
    trainCharacteristics: const [],
    journeyEvent: journeyEvent,
  );

  TestJourneySkeleton limitedNumberOfSegmentProfiles(int maxSpCount) => TestJourneySkeleton(
    journeyName: journeyName,
    journeyProfile: journeyProfile,
    segmentProfiles: segmentProfiles.take(maxSpCount).toList(),
    trainCharacteristics: trainCharacteristics,
    journeyEvent: journeyEvent,
  );
}
