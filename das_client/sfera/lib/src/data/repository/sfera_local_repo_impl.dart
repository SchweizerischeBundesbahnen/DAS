import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/local/tables/journey_profile_table.dart';
import 'package:sfera/src/data/local/tables/segment_profile_table.dart';
import 'package:sfera/src/data/local/tables/train_characteristics_table.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';
import 'package:sfera/src/data/repository/sfera_local_repo.dart';
import 'package:sfera/src/model/journey/journey.dart';

class SferaLocalRepoImpl implements SferaLocalRepo {
  const SferaLocalRepoImpl({required SferaLocalDatabaseService localService}) : _databaseService = localService;

  final SferaLocalDatabaseService _databaseService;

  @override
  Stream<Journey?> journeyStream({required String company, required String trainNumber, required DateTime startDate}) {
    final date = DateTime(startDate.year, startDate.month, startDate.day);
    return _databaseService.observeJourneyProfile(company, trainNumber, date).asyncMap((entity) async {
      if (entity == null) {
        return Future.value(null);
      }

      final journeyProfile = entity.toDomain();
      final segmentProfiles = await _loadSegmentProfiles(journeyProfile);
      final trainCharacteristics = await _loadTrainCharacteristics(journeyProfile);

      return SferaModelMapper.mapToJourney(
        journeyProfile: journeyProfile,
        segmentProfiles: segmentProfiles,
        trainCharacteristics: trainCharacteristics,
      );
    });
  }

  Future<List<TrainCharacteristicsDto>> _loadTrainCharacteristics(JourneyProfileDto journeyProfile) async {
    final trainCharacteristics = <TrainCharacteristicsDto>[];
    for (final tcReference in journeyProfile.trainCharacteristicsRefSet) {
      final trainCharacteristic = await _databaseService.findTrainCharacteristics(
        tcReference.tcId,
        tcReference.versionMajor,
        tcReference.versionMinor,
      );
      if (trainCharacteristic != null) {
        trainCharacteristics.add(trainCharacteristic.toDomain());
      }
    }
    return trainCharacteristics;
  }

  Future<List<SegmentProfileDto>> _loadSegmentProfiles(JourneyProfileDto journeyProfile) async {
    final segmentProfiles = <SegmentProfileDto>[];
    for (final spReference in journeyProfile.segmentProfileReferences) {
      final segmentProfile = await _databaseService.findSegmentProfile(
        spReference.spId,
        spReference.versionMajor,
        spReference.versionMinor,
      );
      if (segmentProfile != null) {
        segmentProfiles.add(segmentProfile.toDomain());
      }
    }
    return segmentProfiles;
  }
}
