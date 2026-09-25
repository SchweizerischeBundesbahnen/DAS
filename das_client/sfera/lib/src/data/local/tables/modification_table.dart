// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:sfera/src/data/local/drift_sfera_local_database_service.dart';
import 'package:sfera/src/model/journey/modification_type.dart';
import 'package:sfera/src/model/modification.dart';

class ModificationTable extends Table {
  TextColumn get identifier => text()();

  DateTimeColumn get date => dateTime()();

  TextColumn get type => textEnum<ModificationType>()();

  @override
  Set<Column<Object>>? get primaryKey => {identifier, date, type};
}

extension ModificationMapperX on Modification {
  ModificationTableCompanion toCompanion() {
    return ModificationTableCompanion.insert(
      identifier: identifier,
      date: date,
      type: type,
    );
  }
}

extension ModificationTableDataX on ModificationTableData {
  Modification toDomain() {
    return Modification(identifier: identifier, date: date, type: type);
  }
}
