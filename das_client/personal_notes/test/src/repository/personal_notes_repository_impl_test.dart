import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_notes/src/api/dto/personal_note_dto.dart';
import 'package:personal_notes/src/api/endpoint/delete_personal_note.dart';
import 'package:personal_notes/src/api/endpoint/personal_notes.dart';
import 'package:personal_notes/src/api/endpoint/save_personal_notes.dart';
import 'package:personal_notes/src/api/personal_notes_api_service.dart';
import 'package:personal_notes/src/data/personal_notes_local_database_service.dart';
import 'package:personal_notes/src/model/personal_note.dart';
import 'package:personal_notes/src/repository/personal_notes_repository_impl.dart';

import 'personal_notes_repository_impl_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<PersonalNotesApiService>(),
  MockSpec<PersonalNotesLocalDatabaseService>(),
  MockSpec<PersonalNotesListRequest>(),
  MockSpec<PersonalNotePutRequest>(),
  MockSpec<PersonalNoteDeleteRequest>(),
])
void main() {
  late PersonalNotesRepositoryImpl testee;
  late MockPersonalNotesApiService mockApiService;
  late MockPersonalNotesLocalDatabaseService mockDatabaseService;
  late MockPersonalNotesListRequest mockListRequest;
  late MockPersonalNotePutRequest mockPutRequest;
  late MockPersonalNoteDeleteRequest mockDeleteRequest;

  setUp(() async {
    mockApiService = MockPersonalNotesApiService();
    mockDatabaseService = MockPersonalNotesLocalDatabaseService();
    mockListRequest = MockPersonalNotesListRequest();
    mockPutRequest = MockPersonalNotePutRequest();
    mockDeleteRequest = MockPersonalNoteDeleteRequest();

    when(mockApiService.personalNotes).thenReturn(mockListRequest);
    when(mockApiService.savePersonalNote).thenReturn(mockPutRequest);
    when(mockApiService.deletePersonalNote).thenReturn(mockDeleteRequest);

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: const []),
    );
    when(mockPutRequest.call(note: anyNamed('note'))).thenAnswer(
      (_) async => PersonalNotePutResponse(headers: const {}),
    );
    when(mockDeleteRequest.call(key: anyNamed('key'))).thenAnswer(
      (_) async => PersonalNoteDeleteResponse(headers: const {}),
    );

    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => const []);
    when(mockDatabaseService.findAllNotes()).thenAnswer((_) async => const []);
    when(mockDatabaseService.saveNote(any)).thenAnswer((_) async {});
    when(mockDatabaseService.deleteNote(any)).thenAnswer((_) async {});

    testee = PersonalNotesRepositoryImpl(
      apiService: mockApiService,
      databaseService: mockDatabaseService,
    );

    // clear repository interactions after initial sync and clean up job
    await untilCalled(mockListRequest.call());
    await Future<void>.delayed(const Duration(milliseconds: 10));

    clearInteractions(mockApiService);
    clearInteractions(mockDatabaseService);
    clearInteractions(mockListRequest);
    clearInteractions(mockPutRequest);
    clearInteractions(mockDeleteRequest);
  });

  test('saveNote_whenCalled_thenSavesToDatabaseAndCallsApi', () async {
    // GIVEN
    final note = _note(locationCode: 'CH001', text: 'Note text', modifiedAt: DateTime(2026, 1, 1, 8));

    // WHEN
    await testee.saveNote(note);

    // THEN
    verify(mockDatabaseService.saveNote(note)).called(1);

    final verification = verify(mockPutRequest.call(note: captureAnyNamed('note')));
    verification.called(1);

    final capturedDto = verification.captured.single as PersonalNoteDto;
    expect(capturedDto.key, note.locationCode);
    expect(capturedDto.value.text, note.text);
    expect(capturedDto.value.showAsFootnote, note.showAsFootnote);
    expect(capturedDto.value.lastModifiedAt, note.lastModifiedAt);
  });

  test('deleteNote_whenCalled_thenDeletesFromDatabaseAndCallsApi', () async {
    // GIVEN
    final note = _note(locationCode: 'CH001', text: 'Note text', modifiedAt: DateTime(2026, 1, 1, 8));

    // WHEN
    await testee.deleteNote(note);

    // THEN
    verify(mockDatabaseService.deleteNote(note)).called(1);
    verify(mockDeleteRequest.call(key: note.locationCode)).called(1);
  });

  test('saveNote_whenSingleUseNote_thenSavesToDatabaseWithoutCallingApi', () async {
    // GIVEN
    final note = _note(
      locationCode: 'CH001',
      text: 'Single use note',
      modifiedAt: DateTime(2026, 1, 1, 8),
      trainIdentification: _trainIdentification(trainNumber: 'ICE 123'),
    );

    // WHEN
    await testee.saveNote(note);

    // THEN
    verify(mockDatabaseService.saveNote(note)).called(1);
    verifyNever(mockPutRequest.call(note: anyNamed('note')));
  });

  test('deleteNote_whenSingleUseNote_thenDeletesFromDatabaseWithoutCallingApi', () async {
    // GIVEN
    final note = _note(
      locationCode: 'CH001',
      text: 'Single use note',
      modifiedAt: DateTime(2026, 1, 1, 8),
      trainIdentification: _trainIdentification(trainNumber: 'ICE 123'),
    );

    // WHEN
    await testee.deleteNote(note);

    // THEN
    verify(mockDatabaseService.deleteNote(note)).called(1);
    verifyNever(mockDeleteRequest.call(key: anyNamed('key')));
  });

  test('cleanUpSingleUseNotes_whenExpired_thenDeletesOnlyExpiredSingleUseNotes', () async {
    // GIVEN
    final now = DateTime.now();
    final expiredSingleUseNote = _note(
      locationCode: 'CH001',
      text: 'expired single use',
      modifiedAt: now.subtract(const Duration(days: 10)),
      trainIdentification: _trainIdentification(
        trainNumber: 'ICE 123',
        date: now.subtract(const Duration(days: 6)),
      ),
    );
    final recentSingleUseNote = _note(
      locationCode: 'CH001',
      text: 'recent single use',
      modifiedAt: now.subtract(const Duration(days: 2)),
      trainIdentification: _trainIdentification(
        trainNumber: 'ICE 456',
        date: now.subtract(const Duration(days: 4)),
      ),
    );
    final normalNote = _note(
      locationCode: 'CH001',
      text: 'personal note',
      modifiedAt: now.subtract(const Duration(days: 20)),
    );

    when(
      mockDatabaseService.findAllNotes(includeDeleted: true),
    ).thenAnswer((_) async => [expiredSingleUseNote, recentSingleUseNote, normalNote]);

    // WHEN
    await testee.cleanUpSingleUseNotes();

    // THEN
    verify(mockDatabaseService.deleteNote(expiredSingleUseNote)).called(1);
    verifyNever(mockDatabaseService.deleteNote(recentSingleUseNote));
    verifyNever(mockDatabaseService.deleteNote(normalNote));
  });

  test('synchronizeNotes_whenRemoteNoteIsNewer_thenStoresRemoteNoteLocally', () async {
    // GIVEN
    final remoteNote = _note(locationCode: 'CH001', text: 'remote', modifiedAt: DateTime(2026, 6, 1));
    final localNote = _note(locationCode: 'CH001', text: 'local', modifiedAt: DateTime(2026, 5, 1));

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: [remoteNote.toDto()]),
    );
    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => [localNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verify(mockDatabaseService.saveNote(remoteNote)).called(1);
    verifyNever(mockPutRequest.call(note: anyNamed('note')));
  });

  test('synchronizeNotes_whenLocalNoteIsNewer_thenPushesLocalNoteToApi', () async {
    // GIVEN
    final remoteNote = _note(locationCode: 'CH001', text: 'remote', modifiedAt: DateTime(2026, 5, 1));
    final localNote = _note(locationCode: 'CH001', text: 'local', modifiedAt: DateTime(2026, 6, 1));

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: [remoteNote.toDto()]),
    );
    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => [localNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verifyNever(mockDatabaseService.saveNote(any));

    final verification = verify(mockPutRequest.call(note: captureAnyNamed('note')));
    verification.called(1);

    final capturedDto = verification.captured.single as PersonalNoteDto;
    expect(capturedDto.key, localNote.locationCode);
    expect(capturedDto.value.text, localNote.text);
    expect(capturedDto.value.showAsFootnote, localNote.showAsFootnote);
    expect(capturedDto.value.lastModifiedAt, localNote.lastModifiedAt);
  });

  test('synchronizeNotes_whenLocalNoteDoesNotExistRemotely_thenPushesLocalNoteToApi', () async {
    // GIVEN
    final localOnlyNote = _note(locationCode: 'CH001', text: 'only local', modifiedAt: DateTime(2026, 7, 1));

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: const []),
    );
    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => [localOnlyNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verify(mockPutRequest.call(note: anyNamed('note'))).called(1);
    verifyNever(mockDatabaseService.saveNote(any));
  });

  test('synchronizeNotes_whenTimestampsAreEqual_thenDoesNotSyncAnyDirection', () async {
    // GIVEN
    final modifiedAt = DateTime(2026, 8, 1);
    final remoteNote = _note(locationCode: 'CH001', text: 'same', modifiedAt: modifiedAt);
    final localNote = _note(locationCode: 'CH001', text: 'same', modifiedAt: modifiedAt);

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: [remoteNote.toDto()]),
    );
    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => [localNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verifyNever(mockDatabaseService.saveNote(any));
    verifyNever(mockPutRequest.call(note: anyNamed('note')));
  });

  test('synchronizeNotes_whenLocalNoteIsDeletedAndRemoteNoteIsOlder_thenDeletesRemoteNote', () async {
    // GIVEN
    final remoteNote = _note(locationCode: 'CH001', text: 'remote', modifiedAt: DateTime(2026, 5, 1));
    final localDeletedNote = _note(
      locationCode: 'CH001',
      text: 'local',
      modifiedAt: DateTime(2026, 6, 1),
      deleted: true,
    );

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: [remoteNote.toDto()]),
    );
    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => [localDeletedNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verify(mockDeleteRequest.call(key: remoteNote.locationCode)).called(1);
    verifyNever(mockDatabaseService.saveNote(any));
    verifyNever(mockPutRequest.call(note: anyNamed('note')));
  });

  test('synchronizeNotes_whenLocalNoteIsDeletedAndRemoteNoteIsNewer_thenRestoresRemoteNoteLocally', () async {
    // GIVEN
    final remoteNote = _note(locationCode: 'CH001', text: 'remote', modifiedAt: DateTime(2026, 7, 1));
    final localDeletedNote = _note(
      locationCode: 'CH001',
      text: 'local',
      modifiedAt: DateTime(2026, 6, 1),
      deleted: true,
    );

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: [remoteNote.toDto()]),
    );
    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => [localDeletedNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verify(mockDatabaseService.saveNote(remoteNote)).called(1);
    verifyNever(mockDeleteRequest.call(key: anyNamed('key')));
    verifyNever(mockPutRequest.call(note: anyNamed('note')));
  });

  test('synchronizeNotes_whenDeletedLocalNoteDoesNotExistRemotely_thenDoesNotRecreateItRemotely', () async {
    // GIVEN
    final localDeletedNote = _note(
      locationCode: 'CH001',
      text: 'local',
      modifiedAt: DateTime(2026, 6, 1),
      deleted: true,
    );

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: const []),
    );
    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => [localDeletedNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verifyNever(mockDatabaseService.saveNote(any));
    verifyNever(mockDeleteRequest.call(key: anyNamed('key')));
    verifyNever(mockPutRequest.call(note: anyNamed('note')));
  });

  test('synchronizeNotes_whenLocalNoteIsSingleUse_thenDoesNotPushItToApi', () async {
    // GIVEN
    final localSingleUseNote = _note(
      locationCode: 'CH001',
      text: 'single use',
      modifiedAt: DateTime(2026, 7, 1),
      trainIdentification: _trainIdentification(trainNumber: 'ICE 123'),
    );

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: const []),
    );
    when(mockDatabaseService.findAllNotes(includeDeleted: true)).thenAnswer((_) async => [localSingleUseNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verifyNever(mockPutRequest.call(note: anyNamed('note')));
    verifyNever(mockDatabaseService.saveNote(any));
  });

  test('synchronizeNotes_whenNormalAndSingleUseNotesShareLocation_thenOnlyNormalNoteIsSynchronized', () async {
    // GIVEN
    final remoteNote = _note(locationCode: 'CH001', text: 'remote', modifiedAt: DateTime(2026, 6, 1));
    final localNote = _note(locationCode: 'CH001', text: 'local', modifiedAt: DateTime(2026, 7, 1));
    final localSingleUseNote = _note(
      locationCode: 'CH001',
      text: 'single use',
      modifiedAt: DateTime(2026, 8, 1),
      trainIdentification: _trainIdentification(trainNumber: 'ICE 123'),
    );

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: [remoteNote.toDto()]),
    );
    when(
      mockDatabaseService.findAllNotes(includeDeleted: true),
    ).thenAnswer((_) async => [localNote, localSingleUseNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    final verification = verify(mockPutRequest.call(note: captureAnyNamed('note')));
    verification.called(1);

    final capturedDto = verification.captured.single as PersonalNoteDto;
    expect(capturedDto.key, localNote.locationCode);
    expect(capturedDto.value.text, localNote.text);
    expect(capturedDto.value.lastModifiedAt, localNote.lastModifiedAt);
    verifyNever(mockDatabaseService.saveNote(localSingleUseNote));
  });
}

PersonalNote _note({
  required String locationCode,
  required String text,
  required DateTime modifiedAt,
  bool showAsFootnote = false,
  TrainIdentification? trainIdentification,
  bool deleted = false,
}) {
  return PersonalNote(
    locationCode: locationCode,
    text: text,
    showAsFootnote: showAsFootnote,
    trainIdentification: trainIdentification,
    deleted: deleted,
    lastModifiedAt: modifiedAt,
  );
}

TrainIdentification _trainIdentification({required String trainNumber, DateTime? date}) {
  return TrainIdentification(
    companyCode: '1285',
    trainNumber: trainNumber,
    date: date ?? DateTime(2026, 1, 1),
  );
}
