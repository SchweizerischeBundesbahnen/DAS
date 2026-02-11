// coverage:ignore-file

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
import 'package:sfera/src/model/db_metrics.dart';

part 'drift_local_database_service.g.dart';

final _log = Logger('SferaDriftLocalDatabaseService');

@DriftDatabase(
  tables: [
    JourneyProfileTable,
    SegmentProfileTable,
    TrainCharacteristicsTable,
  ],
)
class DriftLocalDatabaseService extends _$DriftLocalDatabaseService implements SferaLocalDatabaseService {
  static const int cleanupDays = 2;
  static DriftLocalDatabaseService? _instance;

  static DriftLocalDatabaseService get instance {
    _instance ??= DriftLocalDatabaseService._();
    return _instance!;
  }

  DriftLocalDatabaseService._() : super(driftDatabase(name: 'sfera_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());

  @override
  Future<JourneyProfileTableData?> findJourneyProfile(
    String company,
    String operationalTrainNumber,
    DateTime startDate,
  ) async => _jpManager
      .filter((f) => f.company(company) & f.operationalTrainNumber(operationalTrainNumber) & f.startDate(startDate))
      .getSingleOrNull();

  @override
  Future<SegmentProfileTableData?> findSegmentProfile(String spId, String majorVersion, String minorVersion) async =>
      _spManager
          .filter((f) => f.spId(spId) & f.majorVersion(majorVersion) & f.minorVersion(minorVersion))
          .getSingleOrNull();

  @override
  Future<TrainCharacteristicsTableData?> findTrainCharacteristics(
    String tcId,
    String majorVersion,
    String minorVersion,
  ) async => _tcManager
      .filter((f) => f.tcId(tcId) & f.majorVersion(majorVersion) & f.minorVersion(minorVersion))
      .getSingleOrNull();

  @override
  Stream<JourneyProfileTableData?> observeJourneyProfile(
    String company,
    String operationalTrainNumber,
    DateTime startDate,
  ) => _jpManager
      .filter((f) => f.company(company) & f.operationalTrainNumber(operationalTrainNumber) & f.startDate(startDate))
      .watchSingleOrNull();

  @override
  Future<void> saveJourneyProfile(JourneyProfileDto journeyProfile) async {
    final existingProfile = await findJourneyProfile(
      journeyProfile.trainIdentification.otnId.company,
      journeyProfile.trainIdentification.otnId.operationalTrainNumber,
      journeyProfile.trainIdentification.otnId.startDate,
    );

    final journeyProfileCompanion = journeyProfile.toCompanion(id: existingProfile?.id);

    _log.fine(
      'Writing journey profile to db company=${journeyProfileCompanion.company} operationalTrainNumber=${journeyProfileCompanion.operationalTrainNumber} startDate=${journeyProfileCompanion.startDate}',
    );
    await journeyProfileTable.insertOnConflictUpdate(journeyProfileCompanion);
  }

  @override
  Future<void> saveSegmentProfile(SegmentProfileDto segmentProfile) async {
    final existingProfile = await findSegmentProfile(
      segmentProfile.id,
      segmentProfile.versionMajor,
      segmentProfile.versionMinor,
    );
    if (existingProfile == null) {
      _log.fine(
        'Writing segment profile to db spId=${segmentProfile.id} majorVersion=${segmentProfile.versionMajor} minorVersion=${segmentProfile.versionMinor}',
      );
      await segmentProfileTable.insertOnConflictUpdate(segmentProfile.toCompanion());
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
      _log.fine(
        'Writing train characteristics to db tcId=${trainCharacteristics.tcId} majorVersion=${trainCharacteristics.versionMajor} minorVersion=${trainCharacteristics.versionMinor}',
      );
      await trainCharacteristicsTable.insertOnConflictUpdate(trainCharacteristics.toCompanion());
    } else {
      _log.fine(
        'train characteristics already exists in db tcId=${existingTrainCharacteristics.tcId} majorVersion=${existingTrainCharacteristics.majorVersion} minorVersion=${existingTrainCharacteristics.minorVersion}',
      );
    }
  }

  $$TrainCharacteristicsTableTableTableManager get _tcManager => managers.trainCharacteristicsTable;

  $$JourneyProfileTableTableTableManager get _jpManager => managers.journeyProfileTable;

  $$SegmentProfileTableTableTableManager get _spManager => managers.segmentProfileTable;

  @override
  Future<DbMetrics> retrieveMetrics() async {
    return Future.value(
      DbMetrics(
        jpCount: await _jpManager.count(),
        spCount: await _spManager.count(),
        tcCount: await _tcManager.count(),
      ),
    );
  }

  @override
  Future<int> cleanup() async {
    final deletedCount = await _jpManager
        .filter((f) => f.startDate.isBefore(DateTime.now().subtract(const Duration(days: cleanupDays))))
        .delete();
    _log.info('Deleted $deletedCount old journey profiles from database.');
    return deletedCount;
  }
}
