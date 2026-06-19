import 'package:drift/drift.dart';

class ExternalLinksTable extends Table {
  IntColumn get id => integer()();

  TextColumn get companies => text()();

  TextColumn get titleDe => text()();

  TextColumn get titleFr => text()();

  TextColumn get titleIt => text()();

  TextColumn get linkDe => text()();

  TextColumn get linkFr => text()();

  TextColumn get linkIt => text()();

  DateTimeColumn get lastModifiedAt => dateTime()();

  TextColumn get lastModifiedBy => text()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
