// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:preload/src/data/preload_local_database_service.dart';
import 'package:preload/src/data/tables/s3_preload_table.dart';
import 'package:preload/src/model/s3file.dart';

part 'drift_preload_database_service.g.dart';

@DriftDatabase(
  tables: [
    S3PreloadTable,
  ],
)
class DriftPreloadDatabaseService extends _$DriftPreloadDatabaseService implements PreloadLocalDatabaseService {
  static DriftPreloadDatabaseService? _instance;

  static DriftPreloadDatabaseService get instance {
    _instance ??= DriftPreloadDatabaseService._();
    return _instance!;
  }

  DriftPreloadDatabaseService._() : super(driftDatabase(name: 'preload_db'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());

  @override
  Future<List<S3File>> findAll() {
    return _manager.get().then((it) => it.map((it) => it.toDomain()).toList());
  }

  @override
  Future<int> saveS3File(S3File file) {
    return s3PreloadTable.insertOnConflictUpdate(file.toCompanion());
  }

  $$S3PreloadTableTableTableManager get _manager => managers.s3PreloadTable;

  @override
  Stream<List<S3File>> watchAll() {
    return _manager.watch().map((it) => it.map((it) => it.toDomain()).toList());
  }

  @override
  Future<int> deleteS3File(S3File file) {
    return _manager.filter((f) => f.name(file.name)).delete();
  }
}
