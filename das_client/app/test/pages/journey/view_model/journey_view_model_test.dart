import 'dart:async';

import 'package:app/pages/journey/journey_screen/view_model/personal_note_annotation.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/pages/journey/view_model/sfera_journey_view_model.dart';
import 'package:core_data/component.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:personal_notes/component.dart';
import 'package:ru_indications/component.dart';
import 'package:rxdart/rxdart.dart';
import 'package:settings/component.dart';
import 'package:sfera/component.dart';

import '../../../test_util.dart';
import 'journey_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SettingsRepository>(),
  MockSpec<SferaJourneyViewModel>(),
  MockSpec<RuIndicationsRepository>(),
  MockSpec<PersonalNotesRepository>(),
])
void main() {
  group('JourneyViewModel', () {
    late JourneyViewModel testee;
    late MockSferaJourneyViewModel mockSferaJourneyViewModel;
    late MockRuIndicationsRepository mockRuIndicationsRepository;
    late MockSettingsRepository mockSettingsRepository;
    late MockPersonalNotesRepository mockPersonalNoteRepository;
    late BehaviorSubject<Journey?> sferaJourneySubject;
    late BehaviorSubject<List<PersonalNote>> personalNotesSubject;
    Journey? currentJourney;

    setUp(() {
      mockSferaJourneyViewModel = MockSferaJourneyViewModel();
      mockRuIndicationsRepository = MockRuIndicationsRepository();
      mockSettingsRepository = MockSettingsRepository();
      mockPersonalNoteRepository = MockPersonalNotesRepository();
      sferaJourneySubject = BehaviorSubject<Journey?>.seeded(null);
      personalNotesSubject = BehaviorSubject<List<PersonalNote>>.seeded(const []);
      currentJourney = null;

      when(mockSferaJourneyViewModel.journey).thenAnswer((_) => sferaJourneySubject.stream);
      when(mockSferaJourneyViewModel.journeyValue).thenAnswer((_) => currentJourney);
      when(mockPersonalNoteRepository.observeAllNotes()).thenAnswer((_) => personalNotesSubject.stream);
      when(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: anyNamed('trainIdentification'),
          locationReferences: anyNamed('locationReferences'),
        ),
      ).thenAnswer((_) => Stream.value(const []));

      testee = JourneyViewModel(
        sferaJourneyViewModel: mockSferaJourneyViewModel,
        ruIndicationsRepository: mockRuIndicationsRepository,
        settingsRepository: mockSettingsRepository,
        personalNotesRepository: mockPersonalNoteRepository,
      );
    });

    tearDown(() async {
      testee.dispose();
      await sferaJourneySubject.close();
      await personalNotesSubject.close();
    });

    test('journey_whenSferaJourneyChanges_thenMergesRuIndicationsAndPersonalNoteAnnotations', () async {
      // ARRANGE
      final sferaJourney = _journey(
        trainNumber: '12345',
        servicePoints: [
          _servicePoint(order: 1000, locationCode: 'CH001'),
          _servicePoint(order: 2000, locationCode: 'CH002'),
        ],
      );
      final ruIndications = [
        const RuIndication(order: 1500, title: 'RU middle', text: 'Middle text'),
        const RuIndication(order: 2000, title: 'RU same order', text: 'Same order text'),
      ];

      when(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: sferaJourney.metadata.trainIdentification!,
          locationReferences: const {1000: 'CH001', 2000: 'CH002'},
        ),
      ).thenAnswer((_) => Stream.value(ruIndications));

      // ACT
      final personalNote = PersonalNote(locationCode: 'CH001', text: 'Personal note', showAsFootnote: true);
      personalNotesSubject.add([personalNote]);
      await processStreams();
      currentJourney = sferaJourney;
      sferaJourneySubject.add(sferaJourney);
      await processStreams();
      await processStreams();

      // EXPECT
      verify(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: sferaJourney.metadata.trainIdentification!,
          locationReferences: const {1000: 'CH001', 2000: 'CH002'},
        ),
      ).called(1);

      final emittedJourney = testee.journeyValue;
      expect(emittedJourney, isNotNull);
      expect(emittedJourney!.data.length, 5);
      expect(emittedJourney.data[0], isA<ServicePoint>());
      expect(emittedJourney.data[1], PersonalNoteAnnotation(text: personalNote.text, order: 1000));
      expect(emittedJourney.data[2], ruIndications[0]);
      expect(emittedJourney.data[3], isA<ServicePoint>());
      expect(emittedJourney.data[4], ruIndications[1]);
    });

    test('journey_whenPersonalNotesChange_thenAddsRelevantFootnoteAnnotations', () async {
      // GIVEN
      final journey = _journey(
        trainNumber: '12345',
        servicePoints: [
          _servicePoint(order: 1000, locationCode: 'CH001'),
          _servicePoint(order: 2000, locationCode: 'CH002'),
          _servicePoint(order: 3000, locationCode: 'CH003'),
          _servicePoint(order: 4000, locationCode: 'CH004'),
        ],
      );
      final otherTrainIdentification = TrainIdentification(
        companyCode: '1285',
        trainNumber: '54321',
        date: DateTime(2026, 1, 1),
        operatingDay: DateTime(2026, 1, 2),
      );
      when(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: journey.metadata.trainIdentification!,
          locationReferences: const {1000: 'CH001', 2000: 'CH002', 3000: 'CH003', 4000: 'CH004'},
        ),
      ).thenAnswer((_) => Stream.value(const []));

      // WHEN
      currentJourney = journey;
      sferaJourneySubject.add(journey);
      await processStreams();
      personalNotesSubject.add([
        PersonalNote(locationCode: 'CH001', text: 'General note', showAsFootnote: true),
        PersonalNote(locationCode: 'CH001', text: 'Second footnote', showAsFootnote: true),
        PersonalNote(
          locationCode: 'CH002',
          text: 'Train-specific note',
          showAsFootnote: true,
          trainIdentification: journey.metadata.trainIdentification,
        ),
        PersonalNote(
          locationCode: 'CH003',
          text: 'Note for another train',
          showAsFootnote: true,
          trainIdentification: otherTrainIdentification,
        ),
        PersonalNote(locationCode: 'CH004', text: 'Not a footnote', showAsFootnote: false),
        PersonalNote(locationCode: 'CH005', text: 'Outside the journey', showAsFootnote: true),
      ]);
      await processStreams();

      // THEN
      expect(
        testee.journeyValue!.data.whereType<PersonalNoteAnnotation>(),
        unorderedEquals([
          const PersonalNoteAnnotation(text: 'General note', order: 1000),
          const PersonalNoteAnnotation(text: 'Second footnote', order: 1000),
          const PersonalNoteAnnotation(text: 'Train-specific note', order: 2000),
        ]),
      );
    });

    test('journey_whenAnnotationsAreUnchanged_thenDoesNotEmit', () async {
      // GIVEN
      final servicePoint = _servicePoint(order: 1000, locationCode: 'CH001');
      final journey = _journey(
        trainNumber: '12345',
        servicePoints: [
          servicePoint,
          _servicePoint(order: 2000, locationCode: 'CH002'),
        ],
      );
      final note = PersonalNote(locationCode: 'CH001', text: 'Footnote', showAsFootnote: true);
      final secondNote = PersonalNote(locationCode: 'CH002', text: 'Second footnote', showAsFootnote: true);
      currentJourney = journey;
      sferaJourneySubject.add(journey);
      personalNotesSubject.add([note, secondNote]);
      await processStreams();
      final emittedJourneys = <Journey?>[];
      final subscription = testee.journey.listen(emittedJourneys.add);
      addTearDown(subscription.cancel);
      await processStreams();
      emittedJourneys.clear();

      // WHEN
      personalNotesSubject.add([secondNote.copyWith(), note.copyWith()]);
      await processStreams();
      final hiddenNote = PersonalNote(locationCode: 'CH001', text: 'Hidden note', showAsFootnote: false);
      personalNotesSubject.add([
        hiddenNote,
        note,
        secondNote,
        PersonalNote(locationCode: 'CH003', text: 'Outside the journey', showAsFootnote: true),
        PersonalNote(
          locationCode: 'CH002',
          text: 'Another train',
          showAsFootnote: true,
          trainIdentification: _journey(trainNumber: '54321', servicePoints: []).metadata.trainIdentification,
        ),
      ]);
      await processStreams();

      // THEN
      expect(emittedJourneys, isEmpty);
    });

    test('journey_whenNotesChangeWithoutJourney_thenDoesNotEmit', () async {
      // GIVEN
      await processStreams();
      final emittedJourneys = <Journey?>[];
      final subscription = testee.journey.listen(emittedJourneys.add);
      addTearDown(subscription.cancel);
      await processStreams();
      emittedJourneys.clear();
      final note = PersonalNote(locationCode: 'CH001', text: 'Footnote', showAsFootnote: true);

      // WHEN
      personalNotesSubject.add([note]);
      await processStreams();

      // THEN
      expect(emittedJourneys, isEmpty);
    });

    test('journey_whenNotesAreEditedHiddenOrRemoved_thenUpdatesAnnotations', () async {
      // GIVEN
      final servicePoint = _servicePoint(order: 1000, locationCode: 'CH001');
      final journey = _journey(trainNumber: '12345', servicePoints: [servicePoint]);
      final note = PersonalNote(locationCode: 'CH001', text: 'Original note', showAsFootnote: true);
      currentJourney = journey;
      sferaJourneySubject.add(journey);
      personalNotesSubject.add([note]);
      await processStreams();
      expect(testee.journeyValue!.data.whereType<PersonalNoteAnnotation>(), [
        const PersonalNoteAnnotation(text: 'Original note', order: 1000),
      ]);
      final emittedJourneys = <Journey?>[];
      final subscription = testee.journey.listen(emittedJourneys.add);
      addTearDown(subscription.cancel);
      await processStreams();
      emittedJourneys.clear();

      // WHEN
      personalNotesSubject.add([note.copyWith(text: 'Updated note')]);
      await processStreams();

      // THEN
      expect(testee.journeyValue!.data, [
        servicePoint,
        const PersonalNoteAnnotation(text: 'Updated note', order: 1000),
      ]);
      expect(emittedJourneys, hasLength(1));

      // WHEN
      final hiddenNote = note.copyWith(showAsFootnote: false);
      personalNotesSubject.add([hiddenNote]);
      await processStreams();

      // THEN
      expect(testee.journeyValue!.data, [servicePoint]);
      expect(emittedJourneys, hasLength(2));

      // WHEN
      personalNotesSubject.add([note]);
      await processStreams();
      expect(testee.journeyValue!.data.whereType<PersonalNoteAnnotation>(), hasLength(1));
      personalNotesSubject.add([]);
      await processStreams();

      // THEN
      expect(testee.journeyValue!.data, [servicePoint]);
      expect(emittedJourneys, hasLength(4));
    });

    test('journey_whenTrainChanges_thenReevaluatesNotesAndAnnotationOrders', () async {
      // GIVEN
      final firstJourney = _journey(
        trainNumber: '100',
        servicePoints: [
          _servicePoint(order: 1000, locationCode: 'CH001'),
          _servicePoint(order: 2000, locationCode: 'CH002'),
        ],
      );
      final secondJourney = _journey(
        trainNumber: '200',
        servicePoints: [
          _servicePoint(order: 3000, locationCode: 'CH001'),
          _servicePoint(order: 4000, locationCode: 'CH002'),
        ],
      );
      final generalNote = PersonalNote(locationCode: 'CH001', text: 'General note', showAsFootnote: true);
      final firstTrainNote = PersonalNote(
        locationCode: 'CH002',
        text: 'First train',
        showAsFootnote: true,
        trainIdentification: firstJourney.metadata.trainIdentification,
      );
      final secondTrainNote = PersonalNote(
        locationCode: 'CH002',
        text: 'Second train',
        showAsFootnote: true,
        trainIdentification: secondJourney.metadata.trainIdentification,
      );

      // WHEN
      currentJourney = firstJourney;
      sferaJourneySubject.add(firstJourney);
      personalNotesSubject.add([generalNote, firstTrainNote, secondTrainNote]);
      await processStreams();

      // THEN
      expect(testee.journeyValue!.data.whereType<PersonalNoteAnnotation>(), [
        const PersonalNoteAnnotation(text: 'General note', order: 1000),
        const PersonalNoteAnnotation(text: 'First train', order: 2000),
      ]);

      // WHEN
      currentJourney = secondJourney;
      sferaJourneySubject.add(secondJourney);
      await processStreams();

      // THEN
      expect(testee.journeyValue!.data.whereType<PersonalNoteAnnotation>(), [
        const PersonalNoteAnnotation(text: 'General note', order: 3000),
        const PersonalNoteAnnotation(text: 'Second train', order: 4000),
      ]);
    });

    test('journey_whenTrainChanges_thenOldRuIndicationsAreClearedImmediately', () async {
      // ARRANGE
      final firstJourney = _journey(
        trainNumber: '100',
        servicePoints: [_servicePoint(order: 1000, locationCode: 'CH001')],
      );
      final secondJourney = _journey(
        trainNumber: '200',
        servicePoints: [_servicePoint(order: 1000, locationCode: 'CH002')],
      );
      final secondJourneyController = StreamController<List<RuIndication>>();
      addTearDown(secondJourneyController.close);

      when(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: firstJourney.metadata.trainIdentification!,
          locationReferences: const {1000: 'CH001'},
        ),
      ).thenAnswer((_) => Stream.value([const RuIndication(order: 1100, title: 'RU old', text: 'Old text')]));
      when(
        mockRuIndicationsRepository.fetchRuIndications(
          trainIdentification: secondJourney.metadata.trainIdentification!,
          locationReferences: const {1000: 'CH002'},
        ),
      ).thenAnswer((_) => secondJourneyController.stream);

      // ACT
      currentJourney = firstJourney;
      sferaJourneySubject.add(firstJourney);
      await processStreams();
      await processStreams();

      expect(testee.journeyValue!.data.whereType<RuIndication>(), isNotEmpty);

      currentJourney = secondJourney;
      sferaJourneySubject.add(secondJourney);
      await processStreams();

      // EXPECT
      final journeyAfterTrainChange = testee.journeyValue;
      expect(journeyAfterTrainChange, isNotNull);
      expect(journeyAfterTrainChange!.data.whereType<RuIndication>(), isEmpty);

      secondJourneyController.add(const [RuIndication(order: 1100, title: 'RU new', text: 'New text')]);
      await processStreams();
      expect(testee.journeyValue!.data.whereType<RuIndication>(), isNotEmpty);
    });
  });
}

Journey _journey({required String trainNumber, required List<ServicePoint> servicePoints}) {
  return Journey(
    metadata: Metadata(
      trainIdentification: TrainIdentification(
        companyCode: '1285',
        trainNumber: trainNumber,
        date: DateTime(2026, 1, 1),
        operatingDay: DateTime(2026, 1, 2),
      ),
    ),
    data: servicePoints,
  );
}

ServicePoint _servicePoint({required int order, required String locationCode}) {
  return ServicePoint(
    name: 'ServicePoint $order',
    abbreviation: 'SP$order',
    locationCode: locationCode,
    order: order,
    kilometre: const [],
  );
}
