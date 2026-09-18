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

  setUp(() {
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
    when(mockPutRequest.call(key: anyNamed('key'), note: anyNamed('note'))).thenAnswer(
      (_) async => PersonalNotePutResponse(headers: const {}),
    );
    when(mockDeleteRequest.call(key: anyNamed('key'))).thenAnswer(
      (_) async => PersonalNoteDeleteResponse(headers: const {}),
    );

    when(mockDatabaseService.findAllNotes()).thenAnswer((_) async => const []);
    when(mockDatabaseService.saveNote(any)).thenAnswer((_) async {});
    when(mockDatabaseService.deleteNote(any)).thenAnswer((_) async {});

    testee = PersonalNotesRepositoryImpl(
      apiService: mockApiService,
      databaseService: mockDatabaseService,
    );
  });

  test('saveNote_whenCalled_thenSavesToDatabaseAndCallsApi', () async {
    // GIVEN
    final note = _note(locationCode: 'CH001', text: 'Note text', modifiedAt: DateTime(2026, 1, 1, 8));

    // WHEN
    await testee.saveNote(note);

    // THEN
    verify(mockDatabaseService.saveNote(note)).called(1);

    final verification = verify(
      mockPutRequest.call(key: note.locationCode, note: captureAnyNamed('note')),
    );
    verification.called(1);

    final capturedDto = verification.captured.single as PersonalNoteDto;
    expect(capturedDto.key, note.locationCode);
    expect(capturedDto.value.text, note.text);
    expect(capturedDto.value.showAsFootnote, note.showAsFootnote);
    expect(capturedDto.value.lastModifiedAt, note.lastModifiedAt);
  });

  test('deleteNote_whenCalled_thenDeletesFromDatabaseAndCallsApi', () async {
    // GIVEN
    const locationCode = 'CH001';

    // WHEN
    await testee.deleteNote(locationCode);

    // THEN
    verify(mockDatabaseService.deleteNote(locationCode)).called(1);
    verify(mockDeleteRequest.call(key: locationCode)).called(1);
  });

  test('synchronizeNotes_whenRemoteNoteIsNewer_thenStoresRemoteNoteLocally', () async {
    // GIVEN
    final remoteNote = _note(locationCode: 'CH001', text: 'remote', modifiedAt: DateTime(2026, 6, 1));
    final localNote = _note(locationCode: 'CH001', text: 'local', modifiedAt: DateTime(2026, 5, 1));

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: [remoteNote.toDto()]),
    );
    when(mockDatabaseService.findAllNotes()).thenAnswer((_) async => [localNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verify(mockDatabaseService.saveNote(remoteNote)).called(1);
    verifyNever(mockPutRequest.call(key: anyNamed('key'), note: anyNamed('note')));
  });

  test('synchronizeNotes_whenLocalNoteIsNewer_thenPushesLocalNoteToApi', () async {
    // GIVEN
    final remoteNote = _note(locationCode: 'CH001', text: 'remote', modifiedAt: DateTime(2026, 5, 1));
    final localNote = _note(locationCode: 'CH001', text: 'local', modifiedAt: DateTime(2026, 6, 1));

    when(mockListRequest.call()).thenAnswer(
      (_) async => PersonalNotesListResponse(headers: const {}, body: [remoteNote.toDto()]),
    );
    when(mockDatabaseService.findAllNotes()).thenAnswer((_) async => [localNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verifyNever(mockDatabaseService.saveNote(any));

    final verification = verify(
      mockPutRequest.call(key: localNote.locationCode, note: captureAnyNamed('note')),
    );
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
    when(mockDatabaseService.findAllNotes()).thenAnswer((_) async => [localOnlyNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verify(mockPutRequest.call(key: localOnlyNote.locationCode, note: anyNamed('note'))).called(1);
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
    when(mockDatabaseService.findAllNotes()).thenAnswer((_) async => [localNote]);

    // WHEN
    await testee.synchronizeNotes();

    // THEN
    verifyNever(mockDatabaseService.saveNote(any));
    verifyNever(mockPutRequest.call(key: anyNamed('key'), note: anyNamed('note')));
  });
}

PersonalNote _note({
  required String locationCode,
  required String text,
  required DateTime modifiedAt,
  bool showAsFootnote = false,
}) {
  return PersonalNote(
    locationCode: locationCode,
    text: text,
    showAsFootnote: showAsFootnote,
    lastModifiedAt: modifiedAt,
  );
}
