import 'package:logging/logging.dart';
import 'package:personal_notes/src/api/dto/personal_note_dto.dart';
import 'package:personal_notes/src/api/personal_notes_api_service.dart';
import 'package:personal_notes/src/data/personal_notes_local_database_service.dart';
import 'package:personal_notes/src/model/personal_note.dart';
import 'package:personal_notes/src/repository/personal_notes_repository.dart';

final _log = Logger('PersonalNotesRepositoryImpl');

class PersonalNotesRepositoryImpl({
  required final PersonalNotesApiService _apiService,
  required final PersonalNotesLocalDatabaseService _databaseService,
}) implements PersonalNotesRepository {
  this {
    synchronizeNotes();
  }

  @override
  Future<void> synchronizeNotes() async {
    final response = await _apiService.personalNotes();
    final remoteNotes = response.body.map((it) => it.toDomain()).toList(growable: false);
    final localNotes = await _databaseService.findAllNotes(includeDeleted: true);

    final remoteByKey = <String, PersonalNote>{for (final note in remoteNotes) note.locationCode: note};
    final localByKey = <String, PersonalNote>{for (final note in localNotes) note.locationCode: note};

    for (final remoteNote in remoteNotes) {
      final localNote = localByKey[remoteNote.locationCode];

      if (localNote == null) {
        await _databaseService.saveNote(remoteNote);
        continue;
      }

      if (localNote.deleted) {
        if (remoteNote.lastModifiedAt.isAfter(localNote.lastModifiedAt)) {
          await _databaseService.saveNote(remoteNote);
          continue;
        }

        await _deleteNoteOnRemote(remoteNote.locationCode);
        continue;
      }

      if (remoteNote.lastModifiedAt.isAfter(localNote.lastModifiedAt)) {
        await _databaseService.saveNote(remoteNote);
        continue;
      }

      if (localNote.lastModifiedAt.isAfter(remoteNote.lastModifiedAt)) {
        await _saveNoteToRemote(localNote);
      }
    }

    for (final localNote in localNotes) {
      if (!remoteByKey.containsKey(localNote.locationCode) && !localNote.deleted) {
        await _saveNoteToRemote(localNote);
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
    _saveNoteToRemote(note);
  }

  @override
  Future<void> deleteNote(String locationCode) async {
    await _databaseService.deleteNote(locationCode);
    _deleteNoteOnRemote(locationCode);
  }

  Future<void> _deleteNoteOnRemote(String locationCode) async {
    try {
      await _apiService.deletePersonalNote(key: locationCode);
      _log.fine('Successfully deleted personal note for $locationCode on remote');
    } catch (e) {
      _log.severe('Failed to delete note for $locationCode on remote', e);
    }
  }

  Future<void> _saveNoteToRemote(PersonalNote note) async {
    try {
      await _apiService.savePersonalNote(note: note.toDto());
      _log.fine('Successfully saved $note on remote');
    } catch (e) {
      _log.severe('Failed to save note for $note to remote', e);
    }
  }
}
