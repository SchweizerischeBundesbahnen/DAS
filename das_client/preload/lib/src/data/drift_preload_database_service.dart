// coverage:ignore-file

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:preload/src/data/preload_local_database_service.dart';
import 'package:preload/src/data/tables/s3_preload_table.dart';
import 'package:preload/src/model/s3_file.dart';

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

  DriftPreloadDatabaseService._() : super(_openConnection());

  static QueryExecutor _openConnection() => LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'preload_db.sqlite'));
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
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(onCreate: (m) => m.createAll());

  @override
  Future<List<S3File>> findAll() => _manager.get().then((it) => it.map((it) => it.toDomain()).toList());

  @override
  Future<int> saveS3File(S3File file) => s3PreloadTable.insertOnConflictUpdate(file.toCompanion());

  @override
  Stream<List<S3File>> watchAll() => _manager.watch().map((it) => it.map((it) => it.toDomain()).toList());

  @override
  Future<int> deleteS3File(S3File file) => _manager.filter((f) => f.name(file.name)).delete();

  $$S3PreloadTableTableTableManager get _manager => managers.s3PreloadTable;
}
