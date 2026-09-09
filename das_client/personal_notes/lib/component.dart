import 'package:personal_notes/src/data/drift_personal_notes_database_service.dart';
import 'package:personal_notes/src/repository/personal_notes_repository.dart';
import 'package:personal_notes/src/repository/personal_notes_repository_impl.dart';

export 'package:personal_notes/src/model/personal_note.dart';
export 'package:personal_notes/src/repository/personal_notes_repository.dart';

class PersonalNotesComponent._() {
  static PersonalNotesRepository createRepository() {
    return PersonalNotesRepositoryImpl(databaseService: PersonalNotesDatabaseService.instance);
  }
}
