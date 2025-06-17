import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:logging/logging.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/local/tables/journey_profile_table.dart';
import 'package:sfera/src/data/local/tables/segment_profile_table.dart';
import 'package:sfera/src/data/local/tables/train_characteristics_table.dart';

part 'drift_local_database_service.g.dart';

final _log = Logger('DriftDatabaseService');

@DriftDatabase(
  tables: [
    JourneyProfileTable,
    SegmentProfileTable,
    TrainCharacteristicsTable,
  ],
)
class DriftLocalDatabaseService extends _$DriftLocalDatabaseService implements SferaLocalDatabaseService {
  DriftLocalDatabaseService() : super(driftDatabase(name: 'sfera_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (m) async {
        await m.createAll();
      },
    );
  }

  @override
  Future<JourneyProfileTableData?> findJourneyProfile(
    String company,
    String operationalTrainNumber,
    DateTime startDate,
  ) async {
    return (select(journeyProfileTable)
          ..where((tbl) => tbl.company.equals(company))
          ..where((tbl) => tbl.operationalTrainNumber.equals(operationalTrainNumber))
          ..where((tbl) => tbl.startDate.equals(startDate)))
        .getSingleOrNull();
  }

  @override
  Future<SegmentProfileTableData?> findSegmentProfile(String spId, String majorVersion, String minorVersion) {
    return (select(segmentProfileTable)
          ..where((tbl) => tbl.spId.equals(spId))
          ..where((tbl) => tbl.majorVersion.equals(majorVersion))
          ..where((tbl) => tbl.minorVersion.equals(minorVersion)))
        .getSingleOrNull();
  }

  @override
  Future<TrainCharacteristicsTableData?> findTrainCharacteristics(
    String tcId,
    String majorVersion,
    String minorVersion,
  ) {
    return (select(trainCharacteristicsTable)
          ..where((tbl) => tbl.tcId.equals(tcId))
          ..where((tbl) => tbl.majorVersion.equals(majorVersion))
          ..where((tbl) => tbl.minorVersion.equals(minorVersion)))
        .getSingleOrNull();
  }

  @override
  Stream<JourneyProfileTableData?> observeJourneyProfile(
    String company,
    String operationalTrainNumber,
    DateTime startDate,
  ) {
    return (select(journeyProfileTable)
          ..where((tbl) => tbl.company.equals(company))
          ..where((tbl) => tbl.operationalTrainNumber.equals(operationalTrainNumber))
          ..where((tbl) => tbl.startDate.equals(startDate)))
        .watchSingleOrNull();
  }

  @override
  Future<void> saveJourneyProfile(JourneyProfileDto journeyProfile) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existingProfile = await findJourneyProfile(
      journeyProfile.trainIdentification.otnId.company,
      journeyProfile.trainIdentification.otnId.operationalTrainNumber,
      today, // TODO: Temporary fix, because our backend does not return correct date in Journey Profile
      //journeyProfile.trainIdentification.otnId.startDate);
    );

    final journeyProfileCompanion = journeyProfile.toCompanion(
      id: existingProfile?.id,
      startDate: today,
    );

    _log.fine(
      'Writing journey profile to db company=${journeyProfileCompanion.company} operationalTrainNumber=${journeyProfileCompanion.operationalTrainNumber} startDate=${journeyProfileCompanion.startDate}',
    );
    journeyProfileTable.insertOnConflictUpdate(journeyProfileCompanion);
  }

  @override
  Future<void> saveSegmentProfile(SegmentProfileDto segmentProfile) async {
    final existingProfile = await findSegmentProfile(
      segmentProfile.id,
      segmentProfile.versionMajor,
      segmentProfile.versionMinor,
    );
    if (existingProfile == null) {
      final segmentProfileCompanion = segmentProfile.toCompanion();
      _log.fine(
        'Writing segment profile to db spId=${segmentProfileCompanion.spId} majorVersion=${segmentProfileCompanion.majorVersion} minorVersion=${segmentProfileCompanion.minorVersion}',
      );
      segmentProfileTable.insertOnConflictUpdate(segmentProfileCompanion);
    } else {
      _log.fine(
        'Segment profile already exists in db spId=${segmentProfile.id} majorVersion=${segmentProfile.versionMajor} minorVersion=${segmentProfile.versionMinor}',
      );
    }
  }

  @override
  Future<void> saveTrainCharacteristics(TrainCharacteristicsDto trainCharacteristics) async {
    final existingTrainCharacteristics = await findTrainCharacteristics(
      trainCharacteristics.tcId,
      trainCharacteristics.versionMajor,
      trainCharacteristics.versionMinor,
    );

    if (existingTrainCharacteristics == null) {
      final trainCharacteristicsCompanion = trainCharacteristics.toCompanion();
      _log.fine(
        'Writing train characteristics to db tcId=${trainCharacteristicsCompanion.tcId} majorVersion=${trainCharacteristicsCompanion.majorVersion} minorVersion=${trainCharacteristicsCompanion.minorVersion}',
      );
      trainCharacteristicsTable.insertOnConflictUpdate(trainCharacteristicsCompanion);
    } else {
      _log.fine(
        'train characteristics already exists in db tcId=${existingTrainCharacteristics.tcId} majorVersion=${existingTrainCharacteristics.majorVersion} minorVersion=${existingTrainCharacteristics.minorVersion}',
      );
    }
  }
}
