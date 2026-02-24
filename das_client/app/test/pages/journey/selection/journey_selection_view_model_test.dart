import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:sfera/component.dart';

@GenerateNiceMocks([MockSpec<SferaRepository>()])
import 'journey_selection_view_model_test.mocks.dart';

void main() {
  late SferaRepository mockSferaRepo;
  late JourneySelectionViewModel testee;
  final List<TrainIdentification> callRegister = [];
  final newYears2025 = DateTime.utc(2025, 1, 1);
  final fixedClock = Clock.fixed(newYears2025);

  setUp(() {
    mockSferaRepo = MockSferaRepository();
    withClock(fixedClock, () {
      testee = JourneySelectionViewModel(
        sferaRepo: mockSferaRepo,
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
      testee = JourneySelectionViewModel(sferaRepo: mockSferaRepo, onJourneySelected: (_) async {});
    });
    // ACT
    final state = testee.modelValue;

    // EXPECT
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.trainNumber, isNull);
    expect(selecting.startDate, equals(newYears1970));
    expect(selecting.railwayUndertaking, RailwayUndertaking.sbbP);
    expect(selecting.isInputComplete, isFalse);
    expect(selecting.availableStartDates, hasLength(2));
    expect(selecting.availableStartDates.first, equals(DateTime.utc(1969, 12, 31)));
    expect(selecting.availableStartDates[1], equals(newYears1970));
  });

  test('modelValue_whenThreeHoursBeforeNextDay_thenIsSelectingWithMoreAvailableDates', () {
    // ARRANGE
    final closeToBerchtoldstag1970 = DateTime.utc(1970, 1, 1, 22);
    final newYears1970 = DateTime.utc(1970);
    final clock = Clock.fixed(closeToBerchtoldstag1970);
    withClock(clock, () {
      testee = JourneySelectionViewModel(sferaRepo: mockSferaRepo, onJourneySelected: (_) async {});
    });
    // ACT
    final state = testee.modelValue;

    // EXPECT
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.startDate, equals(newYears1970));
    expect(selecting.availableStartDates, hasLength(3));
    expect(selecting.availableStartDates.first, equals(DateTime.utc(1969, 12, 31)));
    expect(selecting.availableStartDates[1], equals(newYears1970));
    expect(selecting.availableStartDates[2], equals(DateTime.utc(1970, 01, 02)));
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
    expect(selecting.startDate, newYears2025);
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
}
