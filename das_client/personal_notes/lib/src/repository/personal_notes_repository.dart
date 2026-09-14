import 'package:personal_notes/src/model/personal_note.dart';

abstract class PersonalNotesRepository {
  Future<void> synchronizeNotes();

  Future<PersonalNote?> findNote(String locationCode);

  Future<List<PersonalNote>> findAllNotes();

  Future<void> saveNote(PersonalNote note);

  Future<void> deleteNote(String locationCode);
}
