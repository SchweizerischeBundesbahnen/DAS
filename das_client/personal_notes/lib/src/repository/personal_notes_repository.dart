import 'package:personal_notes/src/model/personal_note.dart';

abstract class PersonalNotesRepository {
  /// Watches the notes at the given location. Emits whenever the underlying data changes.
  Stream<List<PersonalNote>> observeNotes(String locationCode);

  /// Watches all notes. Emits whenever the underlying data changes.
  Stream<List<PersonalNote>> observeAllNotes();

  Future<void> saveNote(PersonalNote note);

  Future<void> deleteNote(PersonalNote note);

  Future<void> synchronizeNotes();

  void dispose();
}
