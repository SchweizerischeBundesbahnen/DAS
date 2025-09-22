import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:sfera/component.dart';

@GenerateNiceMocks([MockSpec<SferaRemoteRepo>()])
import 'journey_selection_view_model_test.mocks.dart';

void main() {
  late SferaRemoteRepo mockSferaRemoteRepo;
  late JourneySelectionViewModel testee;

  setUp(() {
    mockSferaRemoteRepo = MockSferaRemoteRepo();
    testee = JourneySelectionViewModel(sferaRemoteRepo: mockSferaRemoteRepo, onJourneySelected: (_) async {});
  });

  tearDown(() {
    testee.dispose();
  });

  test('modelValue_whenInstantiated_thenIsSelectingWithDefaults', () {
    // ARRANGE
    final backInTheSeventies = DateTime(1970);
    final clock = Clock.fixed(backInTheSeventies);
    withClock(clock, () {
      // seventies testee
      testee = JourneySelectionViewModel(sferaRemoteRepo: mockSferaRemoteRepo, onJourneySelected: (_) async {});
    });
    // ACT
    final state = testee.modelValue;

    // EXPECT
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.trainNumber, isNull);
    expect(selecting.startDate, equals(backInTheSeventies));
    expect(selecting.railwayUndertaking, RailwayUndertaking.sbbP);
    expect(selecting.isInputComplete, isFalse);
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

  test('updateDate_whenCalled_thenUpdatesDate', () {
    // ARRANGE
    final newDate = DateTime(2025, 6, 7);

    // ACT
    testee.updateDate(newDate);

    // EXPECT
    final state = testee.modelValue;
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.startDate, newDate);
  });

  test('updateRailwayUndertaking_whenCalled_thenUpdatesRailwayUndertaking', () {
    // ARRANGE
    final newRU = RailwayUndertaking.blsP;

    // ACT
    testee.updateRailwayUndertaking(newRU);

    // EXPECT
    final state = testee.modelValue;
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.railwayUndertaking, newRU);
  });
}
