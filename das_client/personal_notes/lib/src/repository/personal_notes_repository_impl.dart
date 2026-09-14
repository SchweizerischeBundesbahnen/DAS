import 'package:personal_notes/src/api/dto/personal_note_dto.dart';
import 'package:personal_notes/src/api/personal_notes_api_service.dart';
import 'package:personal_notes/src/data/personal_notes_local_database_service.dart';
import 'package:personal_notes/src/model/personal_note.dart';
import 'package:personal_notes/src/repository/personal_notes_repository.dart';

class const PersonalNotesRepositoryImpl({
  required final PersonalNotesApiService _apiService,
  required final PersonalNotesLocalDatabaseService _databaseService,
}) implements PersonalNotesRepository {
  @override
  Future<void> synchronizeNotes() async {
    final response = await _apiService.personalNotes();
    final remoteNotes = response.body.map((it) => it.toDomain()).toList(growable: false);
    final localNotes = await _databaseService.findAllNotes();

    final remoteByKey = <String, PersonalNote>{for (final note in remoteNotes) note.locationCode: note};
    final localByKey = <String, PersonalNote>{for (final note in localNotes) note.locationCode: note};

    for (final remoteNote in remoteNotes) {
      final localNote = localByKey[remoteNote.locationCode];

      if (localNote == null || remoteNote.lastModifiedAt.isAfter(localNote.lastModifiedAt)) {
        await _databaseService.saveNote(remoteNote);
        continue;
      }

      if (localNote.lastModifiedAt.isAfter(remoteNote.lastModifiedAt)) {
        await _apiService.savePersonalNote(
          key: localNote.locationCode,
          note: localNote.toDto(),
        );
      }
    }

    for (final localNote in localNotes) {
      if (!remoteByKey.containsKey(localNote.locationCode)) {
        await _apiService.savePersonalNote(
          key: localNote.locationCode,
          note: localNote.toDto(),
        );
      }
    }
  }

  @override
  Future<PersonalNote?> findNote(String locationCode) => _databaseService.findNote(locationCode);

  @override
  Future<List<PersonalNote>> findAllNotes() => _databaseService.findAllNotes();

  @override
  Future<void> saveNote(PersonalNote note) async {
    await _databaseService.saveNote(note);
    await _apiService.savePersonalNote(key: note.locationCode, note: note.toDto());
  }

  @override
  Future<void> deleteNote(String locationCode) async {
    await _databaseService.deleteNote(locationCode);
    await _apiService.deletePersonalNote(key: locationCode);
  }
}
