// coverage:ignore-file

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:logging/logging.dart';
import 'package:personal_notes/src/data/personal_notes_local_database_service.dart';
import 'package:personal_notes/src/data/tables/personal_notes_table.dart';
import 'package:personal_notes/src/model/personal_note.dart';

part 'drift_personal_notes_database_service.g.dart';

final _log = Logger('PersonalNotesDatabaseService');

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
  Future<List<PersonalNote>> findNotes(String locationCode) async {
    final personalNotes = await _tableManager
        .filter((f) => f.locationCode.equals(locationCode) & f.deleted.equals(false))
        .get();
    return personalNotes.map((it) => it.toDomain()).toList(growable: false);
  }

  @override
  Future<List<PersonalNote>> findAllNotes({bool includeDeleted = false}) async {
    final notes = includeDeleted
        ? await _tableManager.get()
        : await _tableManager.filter((f) => f.deleted.equals(false)).get();

    return notes.map((it) => it.toDomain()).toList(growable: false);
  }

  @override
  Future<void> saveNote(PersonalNote note) {
    return _tableManager.create((_) => note.toCompanion(), mode: .insertOrReplace);
  }

  @override
  Future<void> deleteNote(PersonalNote note) async {
    final trainId = note.trainIdentification;
    final existingNote = await _tableManager
        .filter(
          (f) =>
              f.locationCode.equals(note.locationCode) &
              f.deleted.equals(false) &
              f.trainNumber.equals(trainId?.trainNumber) &
              f.trainDate.equals(trainId?.date) &
              f.trainCompanyCode.equals(trainId?.companyCode) &
              f.trainOperatingDay.equals(trainId?.operatingDay),
        )
        .getSingleOrNull();

    if (existingNote == null) {
      _log.warning('Tried to delete non-existing note for ${note.locationCode} and ${note.trainIdentification}');
      return;
    }

    final tombstone = existingNote.toDomain().copyWith(deleted: true, lastModifiedAt: DateTime.now());
    await saveNote(tombstone);
    _log.fine('Marked note for ${note.locationCode} and ${note.trainIdentification}');
  }

  $$PersonalNotesTableTableTableManager get _tableManager => managers.personalNotesTable;
}
