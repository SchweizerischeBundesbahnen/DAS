// coverage:ignore-file

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sfera/src/data/dto/journey_profile_dto.dart';
import 'package:sfera/src/data/dto/segment_profile_dto.dart';
import 'package:sfera/src/data/dto/train_characteristics_dto.dart';
import 'package:sfera/src/data/local/sfera_local_database_service.dart';
import 'package:sfera/src/data/local/tables/journey_profile_table.dart';
import 'package:sfera/src/data/local/tables/segment_profile_table.dart';
import 'package:sfera/src/data/local/tables/train_characteristics_table.dart';
import 'package:sfera/src/model/sfera_db_metrics.dart';

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

  DriftLocalDatabaseService._() : super(_openConnection());

  static QueryExecutor _openConnection() => LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'sfera_db.sqlite'));
    return NativeDatabase.createInBackground(
      file,
      setup: (db) {
        // settings to improve writing and reduce blocking actions
        db.execute('PRAGMA journal_mode = WAL;');
        db.execute('PRAGMA synchronous = NORMAL;');
      },
    );
  });

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.drop(segmentProfileTable);
        await m.create(segmentProfileTable);
        await m.drop(trainCharacteristicsTable);
        await m.create(trainCharacteristicsTable);
      }

      if (from < 3) {
        await m.drop(journeyProfileTable);
        await m.create(journeyProfileTable);
      }
    },
  );

  @override
  Future<JourneyProfileTableData?> findJourneyProfile(
    String company,
    String operationalTrainNumber,
    DateTime startDate,
  ) async {
    final journeyProfiles = await _jpManager
        .filter((f) => f.company(company) & f.operationalTrainNumber(operationalTrainNumber) & f.startDate(startDate))
        .orderBy((o) => o.version.desc())
        .get();

    return journeyProfiles.firstOrNull;
  }

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
    final otnId = journeyProfile.trainIdentification.otnId;
    _log.fine(
      'Writing journey profile to db company=${otnId.company} operationalTrainNumber=${otnId.operationalTrainNumber} startDate=${otnId.startDate}',
    );
    await journeyProfileTable.insertOnConflictUpdate(journeyProfile.toCompanion());
  }

  @override
  Future<void> saveBulkJourneyProfiles(Iterable<JourneyProfileDto> journeyProfiles) async {
    Insertable<JourneyProfileTableData> mapToCompanion(JourneyProfileDto jp) {
      final otnId = jp.trainIdentification.otnId;
      _log.fine(
        'Writing journey profile to db company=${otnId.company} operationalTrainNumber=${otnId.operationalTrainNumber} startDate=${otnId.startDate}',
      );
      return jp.toCompanion();
    }

    _jpManager.bulkCreate((_) => journeyProfiles.map(mapToCompanion), mode: .insertOrReplace);
  }

  @override
  Future<void> saveSegmentProfile(SegmentProfileDto segmentProfile) =>
      segmentProfileTable.insertOnConflictUpdate(segmentProfile.toCompanion());

  @override
  Future<void> saveBulkSegmentProfiles(Iterable<SegmentProfileDto> segmentProfiles) =>
      _spManager.bulkCreate((_) => segmentProfiles.map((sp) => sp.toCompanion()), mode: .insertOrReplace);

  @override
  Future<void> saveTrainCharacteristics(TrainCharacteristicsDto trainCharacteristics) =>
      trainCharacteristicsTable.insertOnConflictUpdate(trainCharacteristics.toCompanion());

  @override
  Future<void> saveBulkTrainCharacteristics(Iterable<TrainCharacteristicsDto> trainCharacteristics) =>
      _tcManager.bulkCreate((_) => trainCharacteristics.map((tc) => tc.toCompanion()), mode: .insertOrReplace);

  $$TrainCharacteristicsTableTableTableManager get _tcManager => managers.trainCharacteristicsTable;

  $$JourneyProfileTableTableTableManager get _jpManager => managers.journeyProfileTable;

  $$SegmentProfileTableTableTableManager get _spManager => managers.segmentProfileTable;

  @override
  Future<SferaDbMetrics> getMetrics() async {
    return Future.value(
      SferaDbMetrics(
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
