import 'package:personal_notes/src/data/personal_notes_local_database_service.dart';
import 'package:personal_notes/src/model/personal_note.dart';
import 'package:personal_notes/src/repository/personal_notes_repository.dart';

class const PersonalNotesRepositoryImpl({required final PersonalNotesLocalDatabaseService _databaseService})
    implements PersonalNotesRepository {
  @override
  Future<PersonalNote?> findNote(String locationCode) => _databaseService.findNote(locationCode);

  @override
  Future<void> saveNote(PersonalNote note) {
    return _databaseService.saveNote(note);
  }

  @override
  Future<void> deleteNote(String locationCode) {
    return _databaseService.deleteNote(locationCode);
  }
}
