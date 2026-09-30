import 'package:personal_notes/src/model/personal_note.dart';

abstract class PersonalNotesDatabaseService {
  Stream<List<PersonalNote>> observeNotes({required String userId, required String locationCode});

  Stream<List<PersonalNote>> observeAllNotes({required String userId, bool includeDeleted = false});

  Future<List<PersonalNote>> findAllNotes({required String userId, bool includeDeleted = false});

  Future<void> saveNote({required String userId, required PersonalNote note});

  Future<void> deleteNote({required String userId, required PersonalNote note});
}
