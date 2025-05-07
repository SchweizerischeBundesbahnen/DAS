import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/local/entity/journey_profile_entity.dart';
import 'package:sfera/src/data/local/entity/segment_profile_entity.dart';
import 'package:sfera/src/data/local/entity/train_characteristics_entity.dart';

abstract class SferaLocalDatabaseService {
  const SferaLocalDatabaseService._();

  Future<void> saveJourneyProfile(JourneyProfileDto journeyProfile);

  Future<void> saveSegmentProfile(SegmentProfileDto segmentProfile);

  Future<void> saveTrainCharacteristics(TrainCharacteristicsDto trainCharacteristics);

  Future<JourneyProfileEntity?> findJourneyProfile(String company, String operationalTrainNumber, DateTime startDate);

  Future<SegmentProfileEntity?> findSegmentProfile(String spId, String majorVersion, String minorVersion);

  Future<TrainCharacteristicsEntity?> findTrainCharacteristics(String tcId, String majorVersion, String minorVersion);

  Stream<JourneyProfileEntity?> observeJourneyProfile(
      String company, String operationalTrainNumber, DateTime startDate);
}
