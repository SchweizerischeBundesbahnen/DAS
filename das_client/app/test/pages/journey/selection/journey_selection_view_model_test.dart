import 'dart:async';

import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/provider/user_settings.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/component.dart';
import 'package:train_identification/component.dart';

import 'journey_selection_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<SferaRepository>(),
  MockSpec<TrainIdentificationRepository>(),
  MockSpec<UserSettings>(),
])
void main() {
  late SferaRepository mockSferaRepo;
  late MockTrainIdentificationRepository mockTrainIdentificationRepository;
  late MockUserSettings mockUserSettings;
  late JourneySelectionViewModel testee;
  final List<TrainIdentification?> callRegister = [];
  final today = DateTime.utc(2025, 1, 1);
  final tomorrow = DateTime.utc(2025, 1, 2);
  final fixedClock = Clock.fixed(today);

  setUp(() {
    mockSferaRepo = MockSferaRepository();
    mockTrainIdentificationRepository = MockTrainIdentificationRepository();
    mockUserSettings = MockUserSettings();
    withClock(fixedClock, () {
      testee = JourneySelectionViewModel(
        sferaRepo: mockSferaRepo,
        trainIdentificationRepository: mockTrainIdentificationRepository,
        userSettings: mockUserSettings,
        onJourneySelected: (trainIdentification) async {
          callRegister.add(trainIdentification);
        },
      );
    });
  });

  tearDown(() {
    callRegister.clear();
    testee.dispose();
  });

  test('modelValue_whenInstantiated_thenIsSelectingWithDefaults', () {
    // ARRANGE
    final newYears1970 = DateTime.utc(1970);
    final clock = Clock.fixed(newYears1970);
    withClock(clock, () {
      // seventies testee
      testee = JourneySelectionViewModel(
        sferaRepo: mockSferaRepo,
        trainIdentificationRepository: mockTrainIdentificationRepository,
        userSettings: mockUserSettings,
        onJourneySelected: (_) async {},
      );
    });
    // ACT
    final state = testee.modelValue;

    // EXPECT
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.trainNumber, isNull);
    expect(selecting.startDate, equals(newYears1970));
    expect(selecting.railwayUndertaking, null);
    expect(selecting.isInputComplete, isFalse);
    expect(selecting.availableStartDates, hasLength(3));
    expect(selecting.availableStartDates.first, equals(DateTime.utc(1969, 12, 31)));
    expect(selecting.availableStartDates[1], equals(newYears1970));
  });

  test('updateTrainNumber_whenEmpty_thenFormIsNotCompleted', () {
    // ACT
    testee.updateTrainNumber('');

    // EXPECT
    final state = testee.modelValue;
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.trainNumber, '');
    expect(selecting.isInputComplete, isFalse);
  });

  test('updateTrainNumber_whenFilled_thenIsInputCompleteTrue', () {
    // ACT
    testee.updateTrainNumber('1234');

    // EXPECT
    final state = testee.modelValue;
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.trainNumber, '1234');
    expect(selecting.isInputComplete, isTrue);
  });

  test('updateDate_whenDateIsAvailable_thenUpdatesDate', () {
    // ARRANGE
    final newDate = DateTime.utc(2024, 12, 31);

    // ACT
    testee.updateDate(newDate);

    // EXPECT
    final state = testee.modelValue;
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.startDate, newDate);
  });

  test('updateDate_whenDateIsNotAvailable_thenDoesNothing', () {
    // ARRANGE
    final unavailableDate = DateTime.utc(2025, 6, 7);

    // ACT
    testee.updateDate(unavailableDate);

    // EXPECT
    final state = testee.modelValue;
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.startDate, today);
  });

  test('updateRailwayUndertaking_whenCalled_thenUpdatesRailwayUndertaking', () {
    // ARRANGE
    final newRU = RailwayUndertaking.blsP;

    // ACT
    testee.updateRailwayUndertaking([newRU]);

    // EXPECT
    final state = testee.modelValue;
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.railwayUndertaking, newRU);
  });

  test('loadJourney_whenIncomplete_thenDoesNotCallOnJourneySelected', () {
    // ACT
    testee.loadJourney();

    // EXPECT
    expect(callRegister.isEmpty, isTrue);
  });

  test('loadJourney_whenComplete_thenAddsTrainIdentificationToRegister', () {
    // ARRANGE
    testee.updateTrainNumber('123');
    testee.updateRailwayUndertaking([.sbbP]);
    final aTrainId = TrainIdentification(
      ru: .sbbP,
      trainNumber: '123',
      date: fixedClock.now(),
    );

    // ACT
    testee.loadJourney();

    // EXPECT
    expect(callRegister, hasLength(1));
    expect(callRegister.first, equals(aTrainId));
  });

  test('loadJourney_whenCompleteAndWhitespace_thenAddsCleanedTrainIdentificationToRegister', () {
    // ARRANGE
    testee.updateTrainNumber('  123  ');
    testee.updateRailwayUndertaking([.sbbP]);
    final aTrainId = TrainIdentification(
      ru: .sbbP,
      trainNumber: '123',
      date: fixedClock.now(),
    );

    // ACT
    testee.loadJourney();

    // EXPECT
    expect(callRegister, hasLength(1));
    expect(callRegister.first, equals(aTrainId));
  });

  test('loadJourney_whenLowercase_thenAddsTrainIdentificationWithUppercase', () {
    // ARRANGE
    testee.updateTrainNumber('lowercase123a');
    testee.updateRailwayUndertaking([.sbbP]);
    final aTrainId = TrainIdentification(
      ru: .sbbP,
      trainNumber: 'LOWERCASE123A',
      date: fixedClock.now(),
    );

    // ACT
    testee.loadJourney();

    // EXPECT
    expect(callRegister, hasLength(1));
    expect(callRegister.first, equals(aTrainId));
  });

  test('loadJourney_whenNoRu_thenEmitsLoadingCompanyMatches', () async {
    // ARRANGE
    testee.updateTrainNumber('123');
    final searchCompleter = Completer<Set<CompanyMatch>>();
    when(
      mockTrainIdentificationRepository.findTrainIdentifications(
        operationalTrainNumber: anyNamed('operationalTrainNumber'),
      ),
    ).thenAnswer((_) => searchCompleter.future);

    // ACT
    final loadFuture = testee.loadJourney();

    // EXPECT
    expect(testee.modelValue, isA<LoadingCompanyMatches>());
    final state = testee.modelValue as LoadingCompanyMatches;
    expect(state.trainNumber, '123');
    expect(state.startDate, today);

    searchCompleter.complete(<CompanyMatch>{});
    await loadFuture;
  });

  test('loadJourney_whenMultipleMatchesForDay_thenEmitsSelectingCompanyMatch', () async {
    // ARRANGE
    testee.updateTrainNumber('123');
    when(mockUserSettings.lastUsedRailwayUndertaking).thenReturn(.unknown);
    when(mockTrainIdentificationRepository.findTrainIdentifications(operationalTrainNumber: '123')).thenAnswer(
      (_) async => {
        CompanyMatch(ru: .sbbP, startDate: today),
        CompanyMatch(ru: .blsP, startDate: today),
      },
    );

    // ACT
    final result = await testee.loadJourney();

    // EXPECT
    expect(result, isFalse);
    expect(testee.modelValue, isA<SelectingCompanyMatch>());
    final state = testee.modelValue as SelectingCompanyMatch;
    expect(state.trainNumber, '123');
    expect(state.startDate, today);
    expect(state.companyMatches, {
      CompanyMatch(ru: .sbbP, startDate: today),
      CompanyMatch(ru: .blsP, startDate: today),
    });
    expect(state.selectedCompanyMatch, isNull);
    expect(state.isInputComplete, isFalse);
    expect(callRegister, isEmpty);
  });

  test('loadJourney_whenMatchesForSelectedDay_thenOnlyShowExactDayMatches', () async {
    // ARRANGE
    testee.updateTrainNumber('123');
    when(mockUserSettings.lastUsedRailwayUndertaking).thenReturn(.unknown);
    when(mockTrainIdentificationRepository.findTrainIdentifications(operationalTrainNumber: '123')).thenAnswer(
      (_) async => {
        CompanyMatch(ru: .sbbP, startDate: today),
        CompanyMatch(ru: .sbbP, startDate: tomorrow),
        CompanyMatch(ru: .blsP, startDate: today),
      },
    );

    // ACT
    final result = await testee.loadJourney();

    // EXPECT
    expect(result, isFalse);
    expect(testee.modelValue, isA<SelectingCompanyMatch>());
    final state = testee.modelValue as SelectingCompanyMatch;
    expect(state.trainNumber, '123');
    expect(state.startDate, today);
    expect(state.companyMatches, {
      CompanyMatch(ru: .sbbP, startDate: today),
      CompanyMatch(ru: .blsP, startDate: today),
    });
    expect(state.selectedCompanyMatch, isNull);
    expect(state.isInputComplete, isFalse);
    expect(callRegister, isEmpty);
  });

  test('loadJourney_whenNoMatchesForSelectedDay_thenShowOtherDayMatches', () async {
    // ARRANGE
    testee.updateTrainNumber('123');
    when(mockUserSettings.lastUsedRailwayUndertaking).thenReturn(.unknown);
    when(mockTrainIdentificationRepository.findTrainIdentifications(operationalTrainNumber: '123')).thenAnswer(
      (_) async => {
        CompanyMatch(ru: .sbbP, startDate: tomorrow),
      },
    );

    // ACT
    final result = await testee.loadJourney();

    // EXPECT
    expect(result, isFalse);
    expect(testee.modelValue, isA<SelectingCompanyMatch>());
    final state = testee.modelValue as SelectingCompanyMatch;
    expect(state.trainNumber, '123');
    expect(state.startDate, today);
    expect(state.companyMatches, {
      CompanyMatch(ru: .sbbP, startDate: tomorrow),
    });
    expect(state.selectedCompanyMatch, isNull);
    expect(state.isInputComplete, isFalse);
    expect(callRegister, isEmpty);
  });

  test('loadJourney_whenMultipleMatchesForDayAndLastUsedFound_thenLoadsJourneyDirectly', () async {
    // ARRANGE
    testee.updateTrainNumber('123');
    when(mockUserSettings.lastUsedRailwayUndertaking).thenReturn(.blsP);
    when(mockTrainIdentificationRepository.findTrainIdentifications(operationalTrainNumber: '123')).thenAnswer(
      (_) async => {
        CompanyMatch(ru: .sbbP, startDate: today),
        CompanyMatch(ru: .blsP, startDate: today),
      },
    );

    // ACT
    // ACT
    final result = await testee.loadJourney();

    // EXPECT
    expect(result, isTrue);
    expect(callRegister, hasLength(1));
    expect(
      callRegister.first,
      TrainIdentification(
        ru: .blsP,
        trainNumber: '123',
        date: today,
      ),
    );
  });

  test('loadJourney_whenExactlyOneMatchForDay_thenLoadsJourneyDirectly', () async {
    // ARRANGE
    testee.updateTrainNumber('456');
    when(mockTrainIdentificationRepository.findTrainIdentifications(operationalTrainNumber: '456')).thenAnswer(
      (_) async => {
        CompanyMatch(ru: .sbbP, startDate: today),
      },
    );

    // ACT
    final result = await testee.loadJourney();

    // EXPECT
    expect(result, isTrue);
    expect(callRegister, hasLength(1));
    expect(
      callRegister.first,
      TrainIdentification(
        ru: .sbbP,
        trainNumber: '456',
        date: today,
      ),
    );
  });

  test('loadJourney_whenSelectingCompanyMatchAndSelectionSet_thenLoadsSelectedTrain', () async {
    // ARRANGE
    testee.updateTrainNumber('789');
    when(mockUserSettings.lastUsedRailwayUndertaking).thenReturn(.unknown);
    when(mockTrainIdentificationRepository.findTrainIdentifications(operationalTrainNumber: '789')).thenAnswer(
      (_) async => {
        CompanyMatch(ru: .sbbP, startDate: today),
        CompanyMatch(ru: .blsP, startDate: today),
      },
    );
    await testee.loadJourney();

    final selected = CompanyMatch(ru: .blsP, startDate: today);
    testee.updateSelectedCompanyMatch(selected);

    // ACT
    final result = await testee.loadJourney();

    // EXPECT
    expect(result, isTrue);
    expect(callRegister, hasLength(1));
    expect(
      callRegister.first,
      TrainIdentification(
        ru: .blsP,
        trainNumber: '789',
        date: today,
      ),
    );
  });
}
