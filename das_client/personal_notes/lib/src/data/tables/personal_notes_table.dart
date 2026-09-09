// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:personal_notes/component.dart';
import 'package:personal_notes/src/data/drift_personal_notes_database_service.dart';

class PersonalNotesTable extends Table {
  TextColumn get locationCode => text()();

  TextColumn get noteText => text()();

  BoolColumn get showAsFootnote => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {locationCode};
}

extension PersonalNoteMapperX on PersonalNote {
  PersonalNotesTableCompanion toCompanion() {
    return PersonalNotesTableCompanion.insert(
      locationCode: locationCode,
      noteText: text,
      showAsFootnote: showAsFootnote,
    );
  }
}

extension PersonalNotesTableDataX on PersonalNotesTableData {
  PersonalNote toDomain() {
    return PersonalNote(locationCode: locationCode, text: noteText, showAsFootnote: showAsFootnote);
  }
}
