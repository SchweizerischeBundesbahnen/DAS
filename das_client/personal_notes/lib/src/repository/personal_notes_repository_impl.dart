import 'dart:async';

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';
import 'package:personal_notes/component.dart';
import 'package:personal_notes/src/api/dto/personal_note_dto.dart';
import 'package:personal_notes/src/api/endpoint/personal_notes.dart';
import 'package:personal_notes/src/api/personal_notes_api_service.dart';
import 'package:personal_notes/src/data/personal_notes_database_service.dart';

final _log = Logger('PersonalNotesRepositoryImpl');

class PersonalNotesRepositoryImpl({
  required final PersonalNotesApiService _apiService,
  required final PersonalNotesDatabaseService _databaseService,
  required final UserIdProvider _userIdProvider,
}) implements PersonalNotesRepository {
  static const syncRetryDelay = Duration(minutes: 5);
  static const _singleUseNotesRetention = Duration(days: 5);

  this {
    _init();
  }

  Timer? _retryTimer;
  DateTime? _lastSyncDate;

  @override
  Stream<List<PersonalNote>> observeNotes(String locationCode) async* {
    final userId = await _userIdProvider();
    yield* _databaseService.observeNotesForLocation(userId: userId, locationCode: locationCode);
  }

  @override
  Stream<List<PersonalNote>> observeAllNotes() async* {
    final userId = await _userIdProvider();
    yield* _databaseService.observeAllNotes(userId: userId);
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

  @override
  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  @override
  Future<void> synchronizeNotes() async {
    if (_lastSyncDate != null && _lastSyncDate!.isSameDay(DateTime.now())) {
      _log.fine('Sync already run today. Skipped...');
      return;
    }

    final response = await _fetchRemoteNotes();
    if (response == null) return;

    final userId = await _userIdProvider();
    final remoteNotes = response.body.map((it) => it.toDomain()).toList(growable: false);
    final localNotesForSync = (await _databaseService.findAllNotes(userId: userId, includeDeleted: true)).where(
      (note) => note.shouldBeSynchronized,
    );

    final remoteByKey = <String, PersonalNote>{for (final note in remoteNotes) note.locationCode: note};
    final localByKey = <String, PersonalNote>{for (final note in localNotesForSync) note.locationCode: note};

    var syncSucceeded = true;
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

        syncSucceeded &= await _deleteNoteOnRemote(remoteNote.locationCode);
        continue;
      }

      if (remoteNote.lastModifiedAt.isAfter(localNote.lastModifiedAt)) {
        await _databaseService.saveNote(userId: userId, note: remoteNote);
        continue;
      }

      if (localNote.lastModifiedAt.isAfter(remoteNote.lastModifiedAt)) {
        syncSucceeded &= await _saveNoteToRemote(localNote);
      }
    }

    for (final localNote in localNotesForSync) {
      if (!remoteByKey.containsKey(localNote.locationCode) && !localNote.deleted) {
        syncSucceeded &= await _saveNoteToRemote(localNote);
      }
    }

    if (!syncSucceeded) _scheduleRetry();
  }

  @visibleForTesting
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

  Future<PersonalNotesListResponse?> _fetchRemoteNotes() async {
    try {
      return await _apiService.personalNotes();
    } catch (e) {
      _log.severe('Failed to fetch personal notes from remote. Schedule retry...', e);
      _scheduleRetry();
      return null;
    }
  }

  void _scheduleRetry() {
    if (_retryTimer?.isActive ?? false) return;

    _retryTimer = Timer(syncRetryDelay, () {
      _retryTimer = null;
      synchronizeNotes();
    });
  }

  Future<bool> _deleteNoteOnRemote(String locationCode) async {
    try {
      await _apiService.deletePersonalNote(key: locationCode);
      _log.fine('Successfully deleted personal note for $locationCode on remote');
      return true;
    } catch (e) {
      _log.severe('Failed to delete note for $locationCode on remote', e);
      _scheduleRetry();
      return false;
    }
  }

  Future<bool> _saveNoteToRemote(PersonalNote note) async {
    try {
      await _apiService.savePersonalNote(note: note.toDto());
      _log.fine('Successfully saved $note on remote');
      return true;
    } catch (e) {
      _log.severe('Failed to save note for $note to remote', e);
      _scheduleRetry();
      return false;
    }
  }

  void _init() async {
    await cleanUpSingleUseNotes();
  }
}

extension _DateTimeX on DateTime {
  bool isSameDay(DateTime other) => year == other.year && month == other.month && day == other.day;
}
