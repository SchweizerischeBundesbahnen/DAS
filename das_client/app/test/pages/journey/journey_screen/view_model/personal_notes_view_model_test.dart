import 'dart:async';

import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/personal_note_annotation.dart';
import 'package:app/pages/journey/journey_screen/view_model/personal_notes_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_notes/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sfera/component.dart';

import '../../../../test_util.dart';
import 'personal_notes_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyViewModel>(),
  MockSpec<PersonalNotesRepository>(),
  MockSpec<ServicePointModalViewModel>(),
])
void main() {
  late PersonalNotesViewModel testee;
  late MockJourneyViewModel mockJourneyViewModel;
  late MockPersonalNotesRepository mockPersonalNotesRepository;
  late MockServicePointModalViewModel mockServicePointModalViewModel;

  late BehaviorSubject<Journey?> rxJourney;
  late BehaviorSubject<ServicePoint> rxServicePoint;
  late List<List<PersonalNoteAnnotation>> annotationRegister;
  late StreamSubscription<List<PersonalNoteAnnotation>> annotationSubscription;
  late List<List<PersonalNote>> servicePointNotesRegister;
  late StreamSubscription<List<PersonalNote>> servicePointNotesSubscription;
  late BehaviorSubject<List<PersonalNote>> rxStoredNotes;

  final trainIdentification = TrainIdentification(
    companyCode: '1285',
    trainNumber: '1513',
    date: DateTime(2026, 9, 22),
  );
  final otherTrainIdentification = TrainIdentification(
    companyCode: '1285',
    trainNumber: '1809',
    date: DateTime(2026, 9, 22),
  );

  final servicePointA = _servicePoint(locationCode: 'CH001', order: 10);
  final servicePointB = _servicePoint(locationCode: 'CH002', order: 20);
  final servicePointC = _servicePoint(locationCode: 'CH003', order: 30);
  final servicePointD = _servicePoint(locationCode: 'CH004', order: 40);

  Future<void> emitJourney(Journey? journey) async {
    rxJourney.add(journey);
    await processStreams();
  }

  Future<void> emitServicePoint(ServicePoint servicePoint) async {
    rxServicePoint.add(servicePoint);
    await processStreams();
  }

  Future<void> storeNotes(List<PersonalNote> notes) async {
    rxStoredNotes.add(notes);
    await processStreams();
  }

  setUp(() {
    mockJourneyViewModel = MockJourneyViewModel();
    mockPersonalNotesRepository = MockPersonalNotesRepository();
    mockServicePointModalViewModel = MockServicePointModalViewModel();
    rxJourney = BehaviorSubject<Journey?>.seeded(null);
    rxServicePoint = BehaviorSubject<ServicePoint>();
    rxStoredNotes = BehaviorSubject<List<PersonalNote>>.seeded(const []);
    annotationRegister = [];
    servicePointNotesRegister = [];

    when(mockJourneyViewModel.journey).thenAnswer((_) => rxJourney.stream);
    when(mockServicePointModalViewModel.servicePoint).thenAnswer((_) => rxServicePoint.stream);
    when(mockPersonalNotesRepository.observeAllNotes()).thenAnswer((_) => rxStoredNotes.stream);
    when(mockPersonalNotesRepository.observeNotes(any)).thenAnswer((invocation) {
      final locationCode = invocation.positionalArguments.first as String;
      return rxStoredNotes.stream.map((notes) => notes.where((note) => note.locationCode == locationCode).toList());
    });
    when(mockPersonalNotesRepository.saveNote(any)).thenAnswer((invocation) async {
      rxStoredNotes.add([...rxStoredNotes.value, invocation.positionalArguments.first as PersonalNote]);
    });
    when(mockPersonalNotesRepository.deleteNote(any)).thenAnswer((invocation) async {
      final note = invocation.positionalArguments.first as PersonalNote;
      rxStoredNotes.add(rxStoredNotes.value.where((it) => it != note).toList());
    });

    GetIt.I.registerSingleton<JourneyViewModel>(mockJourneyViewModel);
    testee = PersonalNotesViewModel(
      personalNotesRepository: mockPersonalNotesRepository,
      servicePointModalViewModel: mockServicePointModalViewModel,
    );
    annotationSubscription = testee.personalNoteAnnotations.listen(annotationRegister.add);
    servicePointNotesSubscription = testee.servicePointNotes.listen(servicePointNotesRegister.add);
  });

  tearDown(() async {
    await annotationSubscription.cancel();
    await servicePointNotesSubscription.cancel();
    testee.dispose();
    await rxJourney.close();
    await rxServicePoint.close();
    await rxStoredNotes.close();
    await GetIt.I.reset();
  });

  test('locationCode_whenServicePointChanges_thenLoadsPersonalNoteForCurrentLocation', () async {
    // GIVEN
    final note = _personalNote(locationCode: servicePointA.locationCode, text: 'My note', showAsFootnote: false);
    await storeNotes([note]);
    final prioritizedNoteRegister = <PersonalNote?>[];
    final subscription = testee.prioritizedNote.listen(prioritizedNoteRegister.add);

    // WHEN
    await emitServicePoint(servicePointA);

    // THEN
    expect(testee.locationCode, servicePointA.locationCode);
    expect(testee.prioritizedNoteValue, note);
    expect(prioritizedNoteRegister, orderedEquals([null, note]));
    expect(servicePointNotesRegister.last, orderedEquals([note]));
    expect(testee.servicePointHasMultipleNotes, isFalse);
    verify(mockPersonalNotesRepository.observeNotes(servicePointA.locationCode)).called(1);

    await subscription.cancel();
  });

  test('servicePointNotes_whenServicePointChanges_thenWatchesNotesOfNewLocation', () async {
    // GIVEN
    final noteOnA = _personalNote(locationCode: servicePointA.locationCode, text: 'A', showAsFootnote: false);
    final noteOnB = _personalNote(locationCode: servicePointB.locationCode, text: 'B', showAsFootnote: false);
    await storeNotes([noteOnA, noteOnB]);
    await emitServicePoint(servicePointA);
    expect(servicePointNotesRegister.last, orderedEquals([noteOnA]));

    // WHEN
    await emitServicePoint(servicePointB);

    // THEN
    expect(testee.locationCode, servicePointB.locationCode);
    expect(servicePointNotesRegister.last, orderedEquals([noteOnB]));
    expect(testee.prioritizedNoteValue, noteOnB);
  });

  test('servicePointNotes_whenStoredNotesChange_thenEmitsUpdatedNotes', () async {
    // GIVEN
    final note1 = _personalNote(locationCode: servicePointA.locationCode, text: 'Note 1', showAsFootnote: false);
    final note2 = _personalNote(locationCode: servicePointA.locationCode, text: 'Note 2', showAsFootnote: false);
    await storeNotes([note1]);
    await emitServicePoint(servicePointA);

    // WHEN
    await storeNotes([note1, note2]);

    // THEN
    expect(servicePointNotesRegister.last, orderedEquals([note1, note2]));
    expect(testee.servicePointHasMultipleNotes, isTrue);
    verify(mockPersonalNotesRepository.observeNotes(servicePointA.locationCode)).called(1);
  });

  test('servicePointNotes_whenNoteOfOtherTrain_thenFiltersNote', () async {
    // GIVEN
    final generalNote = _personalNote(locationCode: servicePointA.locationCode, text: 'General', showAsFootnote: false);
    final otherTrainNote = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Other train',
      showAsFootnote: false,
      trainIdentification: otherTrainIdentification,
    );
    await storeNotes([generalNote, otherTrainNote]);
    await emitJourney(_journey(data: [servicePointA], currentTrainIdentification: trainIdentification));

    // WHEN
    await emitServicePoint(servicePointA);

    // THEN
    expect(servicePointNotesRegister.last, orderedEquals([generalNote]));
  });

  test('saveNote_whenSingleUse_thenPersistsNoteAndUpdatesValue', () async {
    // GIVEN
    await emitJourney(_journey(data: [servicePointA], currentTrainIdentification: trainIdentification));
    await emitServicePoint(servicePointA);

    // WHEN
    await testee.saveNote(text: 'Saved note', showAsFootnote: false, singleUse: true);
    await processStreams();

    // THEN
    final verificationResult = verify(mockPersonalNotesRepository.saveNote(captureAny));
    final savedNote = verificationResult.captured.single as PersonalNote;
    verificationResult.called(1);
    expect(savedNote.locationCode, servicePointA.locationCode);
    expect(savedNote.text, 'Saved note');
    expect(savedNote.showAsFootnote, isFalse);
    expect(savedNote.trainIdentification, trainIdentification);
    expect(testee.prioritizedNoteValue, savedNote);
    expect(servicePointNotesRegister.last, orderedEquals([savedNote]));
    expect(testee.servicePointHasMultipleNotes, isFalse);
  });

  test('saveNote_whenSingleUseWithoutJourney_thenDoesNotPersistNote', () async {
    // GIVEN
    await emitServicePoint(servicePointA);

    // WHEN
    await testee.saveNote(text: 'Saved note', showAsFootnote: false, singleUse: true);
    await processStreams();

    // THEN
    verifyNever(mockPersonalNotesRepository.saveNote(any));
    expect(testee.prioritizedNoteValue, isNull);
  });

  test('saveNote_whenNoServicePoint_thenDoesNotPersistNote', () async {
    // WHEN
    await testee.saveNote(text: 'Saved note', showAsFootnote: false, singleUse: false);

    // THEN
    verifyNever(mockPersonalNotesRepository.saveNote(any));
  });

  test('saveNote_whenSavedNoteShouldBeShownAsFootnote_thenUpdatesAnnotations', () async {
    // GIVEN
    await emitJourney(_journey(data: [servicePointA]));
    await emitServicePoint(servicePointA);
    expect(annotationRegister.last, isEmpty);

    // WHEN
    await testee.saveNote(text: 'Footnote', showAsFootnote: true, singleUse: false);
    await processStreams();

    // THEN
    expect(
      annotationRegister.last,
      orderedEquals([PersonalNoteAnnotation(text: 'Footnote', order: servicePointA.order)]),
    );
    verify(mockPersonalNotesRepository.observeAllNotes()).called(1);
  });

  test('saveNote_whenRepositoryThrows_thenRethrows', () async {
    // GIVEN
    when(mockPersonalNotesRepository.saveNote(any)).thenThrow(Exception('failed'));
    await emitServicePoint(servicePointA);

    // WHEN & THEN
    await expectLater(
      testee.saveNote(text: 'Note', showAsFootnote: false, singleUse: false),
      throwsException,
    );
  });

  test('deleteNote_whenCalled_thenDeletesNoteAndClearsValue', () async {
    // GIVEN
    final note = _personalNote(locationCode: servicePointA.locationCode, text: 'Delete me', showAsFootnote: false);
    await storeNotes([note]);
    await emitServicePoint(servicePointA);
    expect(testee.prioritizedNoteValue, note);

    // WHEN
    await testee.deleteNote(note);
    await processStreams();

    // THEN
    verify(mockPersonalNotesRepository.deleteNote(note)).called(1);
    expect(testee.prioritizedNoteValue, isNull);
  });

  test('deleteNote_whenDeletedNoteIsFootnote_thenUpdatesAnnotations', () async {
    // GIVEN
    final noteOnA = _personalNote(locationCode: servicePointA.locationCode, text: 'Footnote', showAsFootnote: true);
    await storeNotes([noteOnA]);
    await emitJourney(_journey(data: [servicePointA]));
    await emitServicePoint(servicePointA);
    expect(annotationRegister.last, isNotEmpty);

    // WHEN
    await testee.deleteNote(noteOnA);
    await processStreams();

    // THEN
    expect(annotationRegister.last, isEmpty);
    expect(testee.prioritizedNoteValue, isNull);
  });

  test('deleteNote_whenRepositoryThrows_thenRethrows', () async {
    // GIVEN
    final note = _personalNote(locationCode: servicePointA.locationCode, text: 'Note', showAsFootnote: false);
    when(mockPersonalNotesRepository.deleteNote(any)).thenThrow(Exception('failed'));

    // WHEN & THEN
    await expectLater(testee.deleteNote(note), throwsException);
  });

  test('personalNoteAnnotations_whenJourneyBecomesNull_thenClearsAnnotations', () async {
    // GIVEN
    await storeNotes([_personalNote(locationCode: servicePointA.locationCode, text: 'Footnote', showAsFootnote: true)]);
    await emitJourney(_journey(data: [servicePointA]));
    expect(annotationRegister.last, isNotEmpty);

    // WHEN
    await emitJourney(null);

    // THEN
    expect(annotationRegister.last, isEmpty);
  });

  test('personalNoteAnnotations_whenPersonalNotesAsFootNotes_thenEmitsAsAnnotations', () async {
    // GIVEN
    await storeNotes([
      _personalNote(
        locationCode: servicePointA.locationCode,
        text: 'A footnote',
        showAsFootnote: true,
        trainIdentification: trainIdentification,
      ),
      _personalNote(locationCode: servicePointB.locationCode, text: 'B footnote', showAsFootnote: true),
      _personalNote(
        locationCode: servicePointC.locationCode,
        text: 'C hidden',
        showAsFootnote: false,
        trainIdentification: trainIdentification,
      ),
      _personalNote(
        locationCode: servicePointD.locationCode,
        text: 'D other train',
        showAsFootnote: true,
        trainIdentification: otherTrainIdentification,
      ),
      _personalNote(locationCode: 'Other Location', text: 'Unknown', showAsFootnote: true),
    ]);

    // WHEN
    await emitJourney(
      _journey(
        currentTrainIdentification: trainIdentification,
        data: [servicePointA, servicePointB, servicePointC, servicePointD],
      ),
    );

    // THEN
    expect(
      annotationRegister.last,
      orderedEquals([
        PersonalNoteAnnotation(text: 'A footnote', order: servicePointA.order),
        PersonalNoteAnnotation(text: 'B footnote', order: servicePointB.order),
      ]),
    );
  });

  test('personalNoteAnnotations_whenStoredNotesChange_thenEmitsUpdatedAnnotations', () async {
    // GIVEN
    await emitJourney(_journey(data: [servicePointA, servicePointB]));
    expect(annotationRegister.last, isEmpty);

    // WHEN
    await storeNotes([
      _personalNote(locationCode: servicePointB.locationCode, text: 'B footnote', showAsFootnote: true),
    ]);

    // THEN
    expect(
      annotationRegister.last,
      orderedEquals([PersonalNoteAnnotation(text: 'B footnote', order: servicePointB.order)]),
    );
    verify(mockPersonalNotesRepository.observeAllNotes()).called(1);
  });

  test('personalNoteAnnotations_whenJourneyUpdatesWithChangedServicePoints_thenUpdatesAnnotations', () async {
    // GIVEN
    await storeNotes([
      _personalNote(locationCode: servicePointA.locationCode, text: 'A footnote', showAsFootnote: true),
      _personalNote(locationCode: servicePointC.locationCode, text: 'C footnote', showAsFootnote: true),
    ]);
    await emitJourney(_journey(currentTrainIdentification: trainIdentification, data: [servicePointA, servicePointB]));
    expect(
      annotationRegister.last,
      orderedEquals([PersonalNoteAnnotation(text: 'A footnote', order: servicePointA.order)]),
    );

    // WHEN
    await emitJourney(_journey(currentTrainIdentification: trainIdentification, data: [servicePointC, servicePointB]));

    // THEN
    expect(
      annotationRegister.last,
      orderedEquals([PersonalNoteAnnotation(text: 'C footnote', order: servicePointC.order)]),
    );
  });

  test('personalNoteAnnotations_whenJourneyUpdatesWithEquivalentServicePoints_thenDoesNotEmitAnnotations', () async {
    // GIVEN
    await emitJourney(_journey(data: [servicePointA, servicePointB]));
    final emissionCount = annotationRegister.length;
    final equivalentServicePointA = _servicePoint(locationCode: servicePointA.locationCode, order: servicePointA.order);
    final equivalentServicePointB = _servicePoint(locationCode: servicePointB.locationCode, order: servicePointB.order);

    // WHEN
    await emitJourney(_journey(data: [equivalentServicePointA, equivalentServicePointB]));

    // THEN
    expect(annotationRegister.length, emissionCount);
    expect(annotationRegister.last, isEmpty);
  });

  test('saveNote_whenMultipleNotesAtServicePoint_thenAppendsNoteToList', () async {
    // GIVEN
    final note1 = _personalNote(locationCode: servicePointA.locationCode, text: 'Note 1', showAsFootnote: false);
    await storeNotes([note1]);
    await emitServicePoint(servicePointA);

    // WHEN
    await testee.saveNote(text: 'Note 2', showAsFootnote: false, singleUse: false);
    await processStreams();

    // THEN
    expect(servicePointNotesRegister.last.length, 2);
    expect(servicePointNotesRegister.last.first, note1);
    expect(servicePointNotesRegister.last.last.text, 'Note 2');
    expect(testee.servicePointHasMultipleNotes, isTrue);
  });

  test('servicePointHasMultipleNotes_whenSingleNote_thenReturnsFalse', () async {
    // GIVEN
    final note = _personalNote(locationCode: servicePointA.locationCode, text: 'Single note', showAsFootnote: false);
    await storeNotes([note]);

    // WHEN
    await emitServicePoint(servicePointA);

    // THEN
    expect(testee.servicePointHasMultipleNotes, isFalse);
  });

  test('servicePointHasMultipleNotes_whenMultipleNotes_thenReturnsTrue', () async {
    // GIVEN
    final note1 = _personalNote(locationCode: servicePointA.locationCode, text: 'Note 1', showAsFootnote: false);
    final note2 = _personalNote(locationCode: servicePointA.locationCode, text: 'Note 2', showAsFootnote: false);
    await storeNotes([note1, note2]);

    // WHEN
    await emitServicePoint(servicePointA);

    // THEN
    expect(testee.servicePointHasMultipleNotes, isTrue);
  });

  test('prioritizedNote_whenMultipleNotesExist_thenPrioritizesSingleUseNote', () async {
    // GIVEN
    final generalNote = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'General note',
      showAsFootnote: false,
    );
    final singleUseNote = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Single use note',
      showAsFootnote: false,
      trainIdentification: trainIdentification,
    );
    await storeNotes([generalNote, singleUseNote]);
    await emitJourney(_journey(data: [servicePointA], currentTrainIdentification: trainIdentification));

    // WHEN
    await emitServicePoint(servicePointA);

    // THEN
    expect(testee.prioritizedNoteValue, singleUseNote);
  });

  test('prioritizedNote_whenOnlyGeneralNotes_thenUsesFirstNote', () async {
    // GIVEN
    final note1 = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'First general note',
      showAsFootnote: false,
    );
    final note2 = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Second general note',
      showAsFootnote: false,
    );
    await storeNotes([note1, note2]);

    // WHEN
    await emitServicePoint(servicePointA);

    // THEN
    expect(testee.prioritizedNoteValue, note1);
  });

  test('deleteNote_whenMultipleNotesExist_thenRemovesNoteAndSelectsNewPrioritized', () async {
    // GIVEN
    final note1 = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Note 1',
      showAsFootnote: false,
    );
    final note2 = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Note 2',
      showAsFootnote: false,
      trainIdentification: trainIdentification,
    );
    await storeNotes([note1, note2]);
    await emitJourney(_journey(data: [servicePointA], currentTrainIdentification: trainIdentification));
    await emitServicePoint(servicePointA);
    expect(testee.prioritizedNoteValue, note2);

    // WHEN
    await testee.deleteNote(note2);
    await processStreams();

    // THEN
    verify(mockPersonalNotesRepository.deleteNote(note2)).called(1);
    expect(servicePointNotesRegister.last, orderedEquals([note1]));
    expect(testee.prioritizedNoteValue, note1);
    expect(testee.servicePointHasMultipleNotes, isFalse);
  });

  test('deleteNote_whenDeletedIsLastNote_thenClearsValue', () async {
    // GIVEN
    final note = _personalNote(locationCode: servicePointA.locationCode, text: 'Only note', showAsFootnote: false);
    await storeNotes([note]);
    await emitServicePoint(servicePointA);

    // WHEN
    await testee.deleteNote(note);
    await processStreams();

    // THEN
    verify(mockPersonalNotesRepository.deleteNote(note)).called(1);
    expect(servicePointNotesRegister.last, isEmpty);
    expect(testee.prioritizedNoteValue, isNull);
  });
}

Journey _journey({required List<BaseData> data, TrainIdentification? currentTrainIdentification}) {
  return Journey(
    metadata: Metadata(trainIdentification: currentTrainIdentification),
    data: data,
  );
}

ServicePoint _servicePoint({required String locationCode, required int order}) {
  return ServicePoint(
    name: 'ServicePoint',
    abbreviation: 'SP',
    locationCode: locationCode,
    order: order,
    kilometre: const [],
    isStop: true,
  );
}

PersonalNote _personalNote({
  required String locationCode,
  required String text,
  required bool showAsFootnote,
  TrainIdentification? trainIdentification,
}) {
  return PersonalNote(
    locationCode: locationCode,
    text: text,
    showAsFootnote: showAsFootnote,
    trainIdentification: trainIdentification,
    lastModifiedAt: DateTime(2026, 9, 22, 12),
  );
}
