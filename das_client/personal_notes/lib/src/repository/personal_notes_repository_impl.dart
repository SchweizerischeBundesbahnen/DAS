import 'package:logging/logging.dart';
import 'package:personal_notes/component.dart';
import 'package:personal_notes/src/api/dto/personal_note_dto.dart';
import 'package:personal_notes/src/api/personal_notes_api_service.dart';
import 'package:personal_notes/src/data/personal_notes_database_service.dart';

final _log = Logger('PersonalNotesRepositoryImpl');

class PersonalNotesRepositoryImpl({
  required final PersonalNotesApiService _apiService,
  required final PersonalNotesDatabaseService _databaseService,
  required final UserIdProvider _userIdProvider,
}) implements PersonalNotesRepository {
  static const _singleUseNotesRetention = Duration(days: 5);

  this {
    _init();
  }

  void _init() async {
    await cleanUpSingleUseNotes();
    await synchronizeNotes();
  }

  Future<void> cleanUpSingleUseNotes() async {
    final userId = await _userIdProvider();
    final cutoffDate = DateTime.now().subtract(_singleUseNotesRetention);
    final notesToDelete = (await _databaseService.findAllNotes(userId: userId, includeDeleted: true)).where(
      (note) => note.trainIdentification != null && note.trainIdentification!.date.isBefore(cutoffDate),
    );

    for (final note in notesToDelete) {
      await _databaseService.deleteNote(userId: userId, note: note);
    }
  }

  Future<void> synchronizeNotes() async {
    final userId = await _userIdProvider();
    final response = await _apiService.personalNotes();
    final remoteNotes = response.body.map((it) => it.toDomain()).toList(growable: false);
    final localNotesForSync = (await _databaseService.findAllNotes(
      userId: userId,
      includeDeleted: true,
    )).where((note) => note.shouldBeSynchronized);

    final remoteByKey = <String, PersonalNote>{for (final note in remoteNotes) note.locationCode: note};
    final localByKey = <String, PersonalNote>{for (final note in localNotesForSync) note.locationCode: note};

    for (final remoteNote in remoteNotes) {
      final localNote = localByKey[remoteNote.locationCode];

      if (localNote == null) {
        await _databaseService.saveNote(userId: userId, note: remoteNote);
        continue;
      }

      if (localNote.deleted) {
        if (remoteNote.lastModifiedAt.isAfter(localNote.lastModifiedAt)) {
          await _databaseService.saveNote(userId: userId, note: remoteNote);
          continue;
        }

        await _deleteNoteOnRemote(remoteNote.locationCode);
        continue;
      }

      if (remoteNote.lastModifiedAt.isAfter(localNote.lastModifiedAt)) {
        await _databaseService.saveNote(userId: userId, note: remoteNote);
        continue;
      }

      if (localNote.lastModifiedAt.isAfter(remoteNote.lastModifiedAt)) {
        await _saveNoteToRemote(localNote);
      }
    }

    for (final localNote in localNotesForSync) {
      if (!remoteByKey.containsKey(localNote.locationCode) && !localNote.deleted) {
        await _saveNoteToRemote(localNote);
      }
    }
  }

  @override
  Future<List<PersonalNote>> findNotes(String locationCode) async {
    final userId = await _userIdProvider();
    return _databaseService.findNotes(userId: userId, locationCode: locationCode);
  }

  @override
  Future<List<PersonalNote>> findAllNotes() async {
    final userId = await _userIdProvider();
    return _databaseService.findAllNotes(userId: userId);
  }

  @override
  Future<void> saveNote(PersonalNote note) async {
    final userId = await _userIdProvider();
    await _databaseService.saveNote(userId: userId, note: note);
    if (note.shouldBeSynchronized) {
      _saveNoteToRemote(note);
    }
  }

  @override
  Future<void> deleteNote(PersonalNote note) async {
    final userId = await _userIdProvider();
    await _databaseService.deleteNote(userId: userId, note: note);
    if (note.shouldBeSynchronized) {
      _deleteNoteOnRemote(note.locationCode);
    }
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
