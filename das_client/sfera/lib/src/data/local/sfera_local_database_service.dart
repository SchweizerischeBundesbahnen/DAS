import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/local/drift_local_database_service.dart';
import 'package:sfera/src/model/db_metrics.dart';

abstract class SferaLocalDatabaseService {
  const SferaLocalDatabaseService._();

  Future<void> saveJourneyProfile(JourneyProfileDto journeyProfile);

  Future<void> saveSegmentProfile(SegmentProfileDto segmentProfile);

  Future<void> saveTrainCharacteristics(TrainCharacteristicsDto trainCharacteristics);

  Future<JourneyProfileTableData?> findJourneyProfile(
    String company,
    String operationalTrainNumber,
    DateTime startDate,
  );

  Future<SegmentProfileTableData?> findSegmentProfile(String spId, String majorVersion, String minorVersion);

  Future<TrainCharacteristicsTableData?> findTrainCharacteristics(
    String tcId,
    String majorVersion,
    String minorVersion,
  );

  Stream<JourneyProfileTableData?> observeJourneyProfile(
    String company,
    String operationalTrainNumber,
    DateTime startDate,
  );

  Future<DbMetrics> retrieveMetrics();

  Future<int> cleanup();
}
