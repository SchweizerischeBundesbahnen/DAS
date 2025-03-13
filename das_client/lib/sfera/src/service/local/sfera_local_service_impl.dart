import 'package:das_client/model/journey/journey.dart';
import 'package:das_client/sfera/src/db/repo/sfera_database_repository.dart';
import 'package:das_client/sfera/src/mapper/sfera_model_mapper.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:das_client/sfera/src/service/local/sfera_local_service.dart';

class SferaLocalServiceImpl implements SferaLocalService {
  const SferaLocalServiceImpl({required SferaDatabaseRepository sferaDatabaseRepository})
      : _sferaDatabaseRepository = sferaDatabaseRepository;

  final SferaDatabaseRepository _sferaDatabaseRepository;

  @override
  Stream<Journey?> journeyStream({required String company, required String trainNumber, required DateTime startDate}) {
    final date = DateTime(startDate.year, startDate.month, startDate.day);
    return _sferaDatabaseRepository.observeJourneyProfile(company, trainNumber, date).asyncMap((entity) async {
      if (entity != null) {
        final journeyProfile = entity.toDomain();

        // segment profiles
        final segmentProfiles = <SegmentProfile>[];
        for (final spReference in journeyProfile.segmentProfileReferences) {
          final segmentProfile = await _sferaDatabaseRepository.findSegmentProfile(
              spReference.spId, spReference.versionMajor, spReference.versionMinor);
          if (segmentProfile != null) {
            segmentProfiles.add(segmentProfile.toDomain());
          }
        }

        // train characteristics
        final trainCharacteristics = <TrainCharacteristics>[];
        for (final tcReference in journeyProfile.trainCharacteristicsRefSet) {
          final trainCharacteristic = await _sferaDatabaseRepository.findTrainCharacteristics(
              tcReference.tcId, tcReference.versionMajor, tcReference.versionMinor);
          if (trainCharacteristic != null) {
            trainCharacteristics.add(trainCharacteristic.toDomain());
          }
        }

        return SferaModelMapper.mapToJourney(
          journeyProfile: journeyProfile,
          segmentProfiles: segmentProfiles,
          trainCharacteristics: trainCharacteristics,
        );
      }

      return Future.value(null);
    });
  }
}
