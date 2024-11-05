import 'package:das_client/sfera/sfera_component.dart';
import 'package:das_client/sfera/src/db/journey_profile_entity.dart';
import 'package:das_client/sfera/src/db/segment_profile_entity.dart';
import 'package:fimber/fimber.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class SferaRepositoryImpl implements SferaRepository {
  late final Future<void> _initialized;
  late final Isar _db;

  SferaRepositoryImpl() {
    _initialized = _init();
  }

  Future<void> _init() async {
    Fimber.i('Initializing SferaStore...');
    final dir = await getApplicationDocumentsDirectory();
    _db = await Isar.openAsync(
        schemas: [JourneyProfileEntitySchema, SegmentProfileEntitySchema], directory: dir.path, name: 'das');
  }

  @override
  Future<void> saveJourneyProfile(JourneyProfile journeyProfile) async {
    await _initialized;

    var now = DateTime.now();
    var today = DateTime(now.year, now.month, now.day);
    var existingProfile = await findJourneyProfile(
        journeyProfile.trainIdentification.otnId.company,
        journeyProfile.trainIdentification.otnId.operationalTrainNumber,
        today); // Temporary fix, because our backend does not return correct date in Journey Profile
    //journeyProfile.trainIdentification.otnId.startDate);

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

    var existingProfile =
        await findSegmentProfile(segmentProfile.id, segmentProfile.versionMajor, segmentProfile.versionMinor);
    if (existingProfile == null) {
      final segmentProfileEntity = segmentProfile.toEntity(isarId: _db.segmentProfile.autoIncrement());
      Fimber.i(
          'Writing segment profile to db spId=${segmentProfileEntity.spId} majorVersion=${segmentProfileEntity.majorVersion} minorVersion=${segmentProfileEntity.minorVersion}');
      _db.write((isar) {
        isar.segmentProfile.put(segmentProfileEntity);
      });
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
  Stream<List<JourneyProfileEntity>> observeJourneyProfile(
      String company, String operationalTrainNumber, DateTime startDate) {
    return _db.journeyProfile
        .where()
        .companyEqualTo(company)
        .operationalTrainNumberEqualTo(operationalTrainNumber)
        .startDateEqualTo(startDate)
        .watch(fireImmediately: true);
  }
}
