// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:sfera/src/data/local/drift_sfera_local_database_service.dart';
import 'package:sfera/src/model/journey/modification_type.dart';
import 'package:sfera/src/model/modification.dart';

class AcknowledgedModificationTable extends Table {
  @override
  String get tableName => 'acknowledged_modification_table';

  TextColumn get identifier => text()();

  DateTimeColumn get date => dateTime()();

  TextColumn get type => textEnum<ModificationType>()();

  @override
  Set<Column<Object>>? get primaryKey => {identifier, date, type};
}

extension ModificationMapperX on Modification {
  AcknowledgedModificationTableCompanion toCompanion() {
    return AcknowledgedModificationTableCompanion.insert(
      identifier: identifier,
      date: date,
      type: type,
    );
  }
}

extension AcknowledgedModificationTableDataX on AcknowledgedModificationTableData {
  Modification toDomain() {
    return Modification(identifier: identifier, date: date, type: type);
  }
}
