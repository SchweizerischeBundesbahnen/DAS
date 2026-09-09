import 'package:personal_notes/src/model/personal_note.dart';

abstract class PersonalNotesRepository {
  Future<PersonalNote?> findNote(String locationCode);

  Future<void> saveNote(PersonalNote note);

  Future<void> deleteNote(String locationCode);
}
