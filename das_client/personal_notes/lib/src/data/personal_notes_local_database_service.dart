import 'package:personal_notes/src/model/personal_note.dart';

abstract class PersonalNotesLocalDatabaseService {
  Future<PersonalNote?> findNote(String locationCode);

  Future<List<PersonalNote>> findAllNotes({bool includeDeleted = false});

  Future<void> saveNote(PersonalNote note);

  Future<void> deleteNote(String locationCode);
}
