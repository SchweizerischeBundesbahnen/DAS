// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:preload/src/data/drift_preload_database_service.dart';
import 'package:preload/src/model/s3file.dart';

class S3PreloadTable extends Table {
  TextColumn get name => text()();

  TextColumn get eTag => text()();

  IntColumn get size => integer()();

  TextColumn get status => text()();

  @override
  Set<Column<Object>> get primaryKey => {name};
}

extension S3FileX on S3File {
  S3PreloadTableCompanion toCompanion() {
    return S3PreloadTableCompanion.insert(
      name: name,
      eTag: eTag,
      size: size,
      status: status.name,
    );
  }
}

extension S3PreloadTableDataX on S3PreloadTableData {
  S3File toDomain() {
    return S3File(
      name: name,
      eTag: eTag,
      size: size,
      status: S3FileSyncStatus.values.firstWhere((e) => e.name == status),
    );
  }
}
