import 'package:sfera/src/data/local/db/entity/journey_profile_entity.dart';
import 'package:sfera/src/data/local/db/entity/segment_profile_entity.dart';
import 'package:sfera/src/data/local/db/entity/train_characteristics_entity.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';

abstract class SferaDatabaseRepository {
  const SferaDatabaseRepository._();

  Future<void> saveJourneyProfile(JourneyProfileDto journeyProfile);

  Future<void> saveSegmentProfile(SegmentProfileDto segmentProfile);

  Future<void> saveTrainCharacteristics(TrainCharacteristicsDto trainCharacteristics);

  Future<JourneyProfileEntity?> findJourneyProfile(String company, String operationalTrainNumber, DateTime startDate);

  Future<SegmentProfileEntity?> findSegmentProfile(String spId, String majorVersion, String minorVersion);

  Future<TrainCharacteristicsEntity?> findTrainCharacteristics(String tcId, String majorVersion, String minorVersion);

  Stream<JourneyProfileEntity?> observeJourneyProfile(
      String company, String operationalTrainNumber, DateTime startDate);
}
