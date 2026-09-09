// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:personal_notes/src/data/personal_notes_local_database_service.dart';
import 'package:personal_notes/src/data/tables/personal_notes_table.dart';
import 'package:personal_notes/src/model/personal_note.dart';

part 'drift_personal_notes_database_service.g.dart';

@DriftDatabase(tables: [PersonalNotesTable])
class PersonalNotesDatabaseService._()
    extends _$PersonalNotesDatabaseService
    implements PersonalNotesLocalDatabaseService {
  this : super(driftDatabase(name: 'personal_notes_db'));

  static PersonalNotesDatabaseService? _instance;

  static PersonalNotesDatabaseService get instance {
    _instance ??= PersonalNotesDatabaseService._();
    return _instance!;
  }

  @override
  int get schemaVersion => 1;

  @override
  Future<PersonalNote?> findNote(String locationCode) async {
    final personalNote = await _tableManager.filter((note) => note.locationCode(locationCode)).getSingleOrNull();
    return personalNote?.toDomain();
  }

  @override
  Future<void> saveNote(PersonalNote note) {
    return personalNotesTable.insertOnConflictUpdate(note.toCompanion());
  }

  @override
  Future<void> deleteNote(String locationCode) {
    return _tableManager.filter((note) => note.locationCode(locationCode)).delete();
  }

  $$PersonalNotesTableTableTableManager get _tableManager => managers.personalNotesTable;
}
