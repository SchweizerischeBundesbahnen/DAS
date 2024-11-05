import 'package:das_client/sfera/src/db/journey_profile_entity.dart';
import 'package:das_client/sfera/src/db/segment_profile_entity.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';

abstract class SferaRepository {
  const SferaRepository._();

  Future<void> saveJourneyProfile(JourneyProfile journeyProfile);

  Future<void> saveSegmentProfile(SegmentProfile segmentProfile);

  Future<JourneyProfileEntity?> findJourneyProfile(String company, String operationalTrainNumber, DateTime startDate);

  Future<SegmentProfileEntity?> findSegmentProfile(String spId, String majorVersion, String minorVersion);

  Stream<List<JourneyProfileEntity>> observeJourneyProfile(
      String company, String operationalTrainNumber, DateTime startDate);
}
