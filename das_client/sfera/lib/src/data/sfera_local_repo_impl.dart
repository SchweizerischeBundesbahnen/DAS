import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/sfera_local_repo.dart';
import 'package:sfera/src/data/mapper/sfera_model_mapper.dart';
import 'package:sfera/src/model/journey/journey.dart';

class SferaLocalServiceImpl implements SferaLocalService {
  const SferaLocalServiceImpl({required SferaLocalDatabaseService sferaDatabaseRepository})
      : _sferaDatabaseRepository = sferaDatabaseRepository;

  final SferaLocalDatabaseService _sferaDatabaseRepository;

  @override
  Stream<Journey?> journeyStream({required String company, required String trainNumber, required DateTime startDate}) {
    final date = DateTime(startDate.year, startDate.month, startDate.day);
    return _sferaDatabaseRepository.observeJourneyProfile(company, trainNumber, date).asyncMap((entity) async {
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
      final trainCharacteristic = await _sferaDatabaseRepository.findTrainCharacteristics(
          tcReference.tcId, tcReference.versionMajor, tcReference.versionMinor);
      if (trainCharacteristic != null) {
        trainCharacteristics.add(trainCharacteristic.toDomain());
      }
    }
    return trainCharacteristics;
  }

  Future<List<SegmentProfileDto>> _loadSegmentProfiles(JourneyProfileDto journeyProfile) async {
    final segmentProfiles = <SegmentProfileDto>[];
    for (final spReference in journeyProfile.segmentProfileReferences) {
      final segmentProfile = await _sferaDatabaseRepository.findSegmentProfile(
          spReference.spId, spReference.versionMajor, spReference.versionMinor);
      if (segmentProfile != null) {
        segmentProfiles.add(segmentProfile.toDomain());
      }
    }
    return segmentProfiles;
  }
}
