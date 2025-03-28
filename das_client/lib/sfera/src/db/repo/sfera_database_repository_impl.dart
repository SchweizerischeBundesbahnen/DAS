import 'package:das_client/sfera/src/db/entity/journey_profile_entity.dart';
import 'package:das_client/sfera/src/db/entity/segment_profile_entity.dart';
import 'package:das_client/sfera/src/db/entity/train_characteristics_entity.dart';
import 'package:das_client/sfera/src/db/repo/sfera_database_repository.dart';
import 'package:das_client/sfera/src/model/journey_profile.dart';
import 'package:das_client/sfera/src/model/segment_profile.dart';
import 'package:das_client/sfera/src/model/train_characteristics.dart';
import 'package:fimber/fimber.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class SferaDatabaseRepositoryImpl implements SferaDatabaseRepository {
  late final Future<void> _initialized;
  late final Isar _db;

  SferaDatabaseRepositoryImpl() {
    _initialized = _init();
  }

  Future<void> _init() async {
    Fimber.i('Initializing SferaStore...');
    final dir = await getApplicationDocumentsDirectory();
    _db = await Isar.openAsync(
        schemas: [JourneyProfileEntitySchema, SegmentProfileEntitySchema, TrainCharacteristicsEntitySchema],
        directory: dir.path,
        name: 'das');
  }

  @override
  Future<void> saveJourneyProfile(JourneyProfile journeyProfile) async {
    await _initialized;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existingProfile = await findJourneyProfile(
      journeyProfile.trainIdentification.otnId.company,
      journeyProfile.trainIdentification.otnId.operationalTrainNumber,
      today, // TODO: Temporary fix, because our backend does not return correct date in Journey Profile
      //journeyProfile.trainIdentification.otnId.startDate);
    );

    final journeyProfileEntity =
        journeyProfile.toEntity(id: existingProfile?.id ?? _db.journeyProfile.autoIncrement(), startDate: today);

    Fimber.i(
        'Writing journey profile to db company=${journeyProfileEntity.company} operationalTrainNumber=${journeyProfileEntity.operationalTrainNumber} startDate=${journeyProfileEntity.startDate}');
    await _db.writeAsync((isar) {
      isar.journeyProfile.put(journeyProfileEntity);
    });
  }

  @override
  Future<void> saveSegmentProfile(SegmentProfile segmentProfile) async {
    await _initialized;

    final existingProfile =
        await findSegmentProfile(segmentProfile.id, segmentProfile.versionMajor, segmentProfile.versionMinor);
    if (existingProfile == null) {
      final segmentProfileEntity = segmentProfile.toEntity(isarId: _db.segmentProfile.autoIncrement());
      Fimber.i(
          'Writing segment profile to db spId=${segmentProfileEntity.spId} majorVersion=${segmentProfileEntity.majorVersion} minorVersion=${segmentProfileEntity.minorVersion}');
      _db.write((isar) => isar.segmentProfile.put(segmentProfileEntity));
    } else {
      Fimber.i(
          'Segment profile already exists in db spId=${segmentProfile.id} majorVersion=${segmentProfile.versionMajor} minorVersion=${segmentProfile.versionMinor}');
    }
  }

  @override
  Future<JourneyProfileEntity?> findJourneyProfile(
      String company, String operationalTrainNumber, DateTime startDate) async {
    await _initialized;
    return _db.journeyProfile
        .where()
        .companyEqualTo(company)
        .operationalTrainNumberEqualTo(operationalTrainNumber)
        .startDateEqualTo(startDate)
        .findFirst();
  }

  @override
  Future<SegmentProfileEntity?> findSegmentProfile(String spId, String majorVersion, String minorVersion) async {
    await _initialized;
    return _db.segmentProfile
        .where()
        .spIdEqualTo(spId)
        .majorVersionEqualTo(majorVersion)
        .minorVersionEqualTo(minorVersion)
        .findFirst();
  }

  @override
  Stream<JourneyProfileEntity?> observeJourneyProfile(
      String company, String operationalTrainNumber, DateTime startDate) async* {
    await _initialized;

    yield* _db.journeyProfile
        .where()
        .companyEqualTo(company)
        .operationalTrainNumberEqualTo(operationalTrainNumber)
        .startDateEqualTo(startDate)
        .watch(fireImmediately: true)
        .map((journeyProfiles) => journeyProfiles.firstOrNull);
  }

  @override
  Future<TrainCharacteristicsEntity?> findTrainCharacteristics(
      String tcId, String majorVersion, String minorVersion) async {
    await _initialized;
    return _db.trainCharacteristics
        .where()
        .tcIdEqualTo(tcId)
        .majorVersionEqualTo(majorVersion)
        .minorVersionEqualTo(minorVersion)
        .findFirst();
  }

  @override
  Future<void> saveTrainCharacteristics(TrainCharacteristics trainCharacteristics) async {
    await _initialized;

    final existingTrainCharacteristics = await findTrainCharacteristics(
        trainCharacteristics.tcId, trainCharacteristics.versionMajor, trainCharacteristics.versionMinor);
    if (existingTrainCharacteristics == null) {
      final trainCharacteristicsEntity =
          trainCharacteristics.toEntity(isarId: _db.trainCharacteristics.autoIncrement());
      Fimber.i(
          'Writing train characteristics to db tcId=${trainCharacteristicsEntity.tcId} majorVersion=${trainCharacteristicsEntity.majorVersion} minorVersion=${trainCharacteristicsEntity.minorVersion}');
      _db.write((isar) => isar.trainCharacteristics.put(trainCharacteristicsEntity));
    } else {
      Fimber.i(
          'train characteristics already exists in db tcId=${existingTrainCharacteristics.tcId} majorVersion=${existingTrainCharacteristics.majorVersion} minorVersion=${existingTrainCharacteristics.minorVersion}');
    }
  }
}
