import 'package:app/pages/journey/train_selection/train_journey_selection_model.dart';
import 'package:app/pages/journey/train_selection/train_journey_selection_view_model.dart';
import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  late TrainJourneySelectionViewModel testee;

  setUp(() {
    testee = TrainJourneySelectionViewModel();
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
      testee = TrainJourneySelectionViewModel();
    });
    // ACT
    final state = testee.modelValue;

    // EXPECT
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.operationalTrainNumber, isNull);
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
    expect(selecting.operationalTrainNumber, '');
    expect(selecting.isInputComplete, isFalse);
  });

  test('updateTrainNumber_whenFilled_thenIsInputCompleteTrue', () {
    // ACT
    testee.updateTrainNumber('1234');

    // EXPECT
    final state = testee.modelValue;
    expect(state, isA<Selecting>());
    final selecting = state as Selecting;
    expect(selecting.operationalTrainNumber, '1234');
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

  // test('updateTrainNumber_whenAllFieldsSetAndInputComplete_thenLoadedState', () {
  //   // ARRANGE
  //   final date = DateTime(2025, 6, 7);
  //   final ru = RailwayUndertaking.sbbP;
  //
  //   // ACT
  //   testee.updateTrainNumber('1234');
  //   testee.updateDate(date);
  //   testee.updateRailwayUndertaking(ru);
  //
  //   // EXPECT
  //   final state = testee.modelValue;
  //   expect(state, isA<Loaded>());
  //   final loaded = state as Loaded;
  //   expect(loaded.trainJourneyIdentification.trainNumber, '1234');
  //   expect(loaded.trainJourneyIdentification.date, date);
  //   expect(loaded.trainJourneyIdentification.ru, ru);
  // });

  // test('model_stream_whenStateChanges_thenEmitsCorrectStates', () async {
  //   // ARRANGE
  //   final emitted = <TrainJourneySelectionModel>[];
  //   final sub = testee.model.listen(emitted.add);
  //
  //   // ACT
  //   testee.updateTrainNumber('1234');
  //   testee.updateDate(DateTime(2025, 6, 7));
  //   testee.updateRailwayUndertaking(RailwayUndertaking.sbbP);
  //
  //   await Future.delayed(Duration.zero);
  //
  //   // EXPECT
  //   expect(emitted.any((s) => s is Loaded), isTrue);
  //   expect(emitted.any((s) => s is Error), isTrue);
  //   expect(emitted.last, isA<Selecting>());
  //
  //   await sub.cancel();
  // });
}
