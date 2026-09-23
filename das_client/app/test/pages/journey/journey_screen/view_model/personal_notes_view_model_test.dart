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

  setUp(() {
    mockJourneyViewModel = MockJourneyViewModel();
    mockPersonalNotesRepository = MockPersonalNotesRepository();
    mockServicePointModalViewModel = MockServicePointModalViewModel();
    rxJourney = BehaviorSubject<Journey?>.seeded(null);
    rxServicePoint = BehaviorSubject<ServicePoint>();
    annotationRegister = [];
    servicePointNotesRegister = [];

    when(mockJourneyViewModel.journey).thenAnswer((_) => rxJourney.stream);
    when(mockServicePointModalViewModel.servicePoint).thenAnswer((_) => rxServicePoint.stream);

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
    await GetIt.I.reset();
  });

  test('locationCode_whenServicePointChanges_thenLoadsPersonalNoteForCurrentLocation', () async {
    // GIVEN
    final note = _personalNote(locationCode: servicePointA.locationCode, text: 'My note', showAsFootnote: false);
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [note]);
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

    await subscription.cancel();
  });

  test('saveNote_whenSingleUse_thenPersistsNoteAndUpdatesValue', () async {
    // GIVEN
    await emitJourney(_journey(data: [servicePointA], currentTrainIdentification: trainIdentification));
    await emitServicePoint(servicePointA);
    clearInteractions(mockPersonalNotesRepository);

    // WHEN
    await testee.saveNote(text: 'Saved note', showAsFootnote: false, singleUse: true);
    await processStreams();

    // THEN
    verifyNever(mockPersonalNotesRepository.findAllNotes());
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

  test('saveNote_whenSavedNoteShouldBeShownAsFootnote_thenReloadsAnnotations', () async {
    // GIVEN
    var allNotes = <PersonalNote>[];
    final savedNote = _personalNote(locationCode: servicePointA.locationCode, text: 'Footnote', showAsFootnote: true);
    when(mockPersonalNotesRepository.findAllNotes()).thenAnswer((_) async => allNotes);
    when(mockPersonalNotesRepository.saveNote(any)).thenAnswer((_) async {
      allNotes = [savedNote];
    });
    await emitJourney(_journey(data: [servicePointA]));
    await emitServicePoint(servicePointA);

    // WHEN
    await testee.saveNote(text: 'Footnote', showAsFootnote: true, singleUse: false);
    await processStreams();

    // THEN
    expect(
      annotationRegister.last,
      orderedEquals([PersonalNoteAnnotation(text: 'Footnote', order: servicePointA.order)]),
    );
    verify(mockPersonalNotesRepository.findAllNotes()).called(2);
  });

  test('deleteNote_whenCalled_thenDeletesNoteAndClearsValue', () async {
    // GIVEN
    final note = _personalNote(locationCode: servicePointA.locationCode, text: 'Delete me', showAsFootnote: false);
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [note]);
    await emitServicePoint(servicePointA);

    // WHEN
    await testee.deleteNote(note);
    await processStreams();

    // THEN
    verifyNever(mockPersonalNotesRepository.findAllNotes());
    verify(mockPersonalNotesRepository.deleteNote(note)).called(1);
    expect(testee.prioritizedNoteValue, isNull);
  });

  test('deleteNote_whenDeletedNoteIsFootnote_thenReloadsAnnotations', () async {
    // GIVEN
    final noteOnA = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Footnote',
      showAsFootnote: true,
    );
    var allNotes = <PersonalNote>[noteOnA];
    when(mockPersonalNotesRepository.findAllNotes()).thenAnswer((_) async => allNotes);
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [noteOnA]);
    when(mockPersonalNotesRepository.deleteNote(noteOnA)).thenAnswer((_) async {
      allNotes = [];
    });
    await emitJourney(_journey(data: [servicePointA]));
    await emitServicePoint(servicePointA);

    // WHEN
    await testee.deleteNote(noteOnA);
    await processStreams();

    // THEN
    expect(annotationRegister.last, isEmpty);
    expect(testee.prioritizedNoteValue, isNull);
  });

  test('personalNoteAnnotations_whenJourneyBecomesNull_thenClearsAnnotations', () async {
    // GIVEN
    when(mockPersonalNotesRepository.findAllNotes()).thenAnswer(
      (_) async => [
        _personalNote(locationCode: servicePointA.locationCode, text: 'Footnote', showAsFootnote: true),
      ],
    );
    await emitJourney(_journey(data: [servicePointA]));
    expect(annotationRegister.last, isNotEmpty);

    // WHEN
    await emitJourney(null);

    // THEN
    expect(annotationRegister.last, isEmpty);
  });

  test(
    'personalNoteAnnotations_whenPersonalNotesAsFootNotes_thenEmitsAsAnnotations',
    () async {
      // GIVEN
      when(mockPersonalNotesRepository.findAllNotes()).thenAnswer(
        (_) async => [
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
        ],
      );

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
    },
  );

  test(
    'personalNoteAnnotations_whenJourneyUpdatesWithChangedServicePoints_thenReloadsAnnotations',
    () async {
      // GIVEN
      var allNotes = <PersonalNote>[
        _personalNote(locationCode: servicePointA.locationCode, text: 'A footnote', showAsFootnote: true),
      ];
      when(mockPersonalNotesRepository.findAllNotes()).thenAnswer((_) async => allNotes);
      await emitJourney(
        _journey(
          currentTrainIdentification: trainIdentification,
          data: [servicePointA, servicePointB],
        ),
      );
      clearInteractions(mockPersonalNotesRepository);
      allNotes = [_personalNote(locationCode: servicePointC.locationCode, text: 'C footnote', showAsFootnote: true)];

      // WHEN
      await emitJourney(
        _journey(
          currentTrainIdentification: trainIdentification,
          data: [servicePointC, servicePointB],
        ),
      );

      // THEN
      verify(mockPersonalNotesRepository.findAllNotes()).called(1);
      expect(
        annotationRegister.last,
        orderedEquals([PersonalNoteAnnotation(text: 'C footnote', order: servicePointC.order)]),
      );
    },
  );

  test(
    'personalNoteAnnotations_whenJourneyUpdatesWithEquivalentServicePoints_thenDoesNotReloadAnnotations',
    () async {
      // GIVEN
      await emitJourney(_journey(data: [servicePointA, servicePointB]));
      clearInteractions(mockPersonalNotesRepository);
      final equivalentServicePointA = _servicePoint(
        locationCode: servicePointA.locationCode,
        order: servicePointA.order,
      );
      final equivalentServicePointB = _servicePoint(
        locationCode: servicePointB.locationCode,
        order: servicePointB.order,
      );

      // WHEN
      await emitJourney(_journey(data: [equivalentServicePointA, equivalentServicePointB]));

      // THEN
      verifyNever(mockPersonalNotesRepository.findAllNotes());
      expect(annotationRegister.last, isEmpty);
    },
  );

  test('saveNote_whenMultipleNotesAtServicePoint_thenAppendsNoteToList', () async {
    // GIVEN
    final note1 = _personalNote(locationCode: servicePointA.locationCode, text: 'Note 1', showAsFootnote: false);
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [note1]);
    await emitServicePoint(servicePointA);
    clearInteractions(mockPersonalNotesRepository);

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
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [note]);

    // WHEN
    await emitServicePoint(servicePointA);

    // THEN
    expect(testee.servicePointHasMultipleNotes, isFalse);
  });

  test('servicePointHasMultipleNotes_whenMultipleNotes_thenReturnsTrue', () async {
    // GIVEN
    final note1 = _personalNote(locationCode: servicePointA.locationCode, text: 'Note 1', showAsFootnote: false);
    final note2 = _personalNote(locationCode: servicePointA.locationCode, text: 'Note 2', showAsFootnote: false);
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [note1, note2]);

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
      trainIdentification: null,
    );
    final singleUseNote = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Single use note',
      showAsFootnote: false,
      trainIdentification: trainIdentification,
    );
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode))
        .thenAnswer((_) async => [generalNote, singleUseNote]);

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
      trainIdentification: null,
    );
    final note2 = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Second general note',
      showAsFootnote: false,
      trainIdentification: null,
    );
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [note1, note2]);

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
      trainIdentification: null,
    );
    final note2 = _personalNote(
      locationCode: servicePointA.locationCode,
      text: 'Note 2',
      showAsFootnote: false,
      trainIdentification: trainIdentification,
    );
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [note1, note2]);
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
    when(mockPersonalNotesRepository.findNotes(servicePointA.locationCode)).thenAnswer((_) async => [note]);
    await emitServicePoint(servicePointA);
    final prioritizedNoteRegister = <PersonalNote?>[];
    final subscription = testee.prioritizedNote.listen(prioritizedNoteRegister.add);

    // WHEN
    await testee.deleteNote(note);
    await processStreams();

    // THEN
    verify(mockPersonalNotesRepository.deleteNote(note)).called(1);
    expect(servicePointNotesRegister.last, isEmpty);
    expect(testee.prioritizedNoteValue, isNull);

    await subscription.cancel();
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
