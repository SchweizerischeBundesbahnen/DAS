import 'dart:async';

import 'package:app/extension/datetime_extension.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sfera/src/model/journey/journey.dart';
import 'package:sfera/src/model/journey/metadata.dart';

import 'arrival_departure_time_view_model_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<JourneyTableViewModel>(),
])
void main() {
  late ArrivalDepartureTimeViewModel testee;
  late StreamController<Journey?> journeyStreamController;
  late MockJourneyTableViewModel mockJourneyTableViewModel;

  setUp(() {
    GetIt.I.registerSingleton(TimeConstants());
    journeyStreamController = StreamController<Journey?>();
    mockJourneyTableViewModel = MockJourneyTableViewModel();
    when(mockJourneyTableViewModel.journey).thenAnswer((_) => journeyStreamController.stream);
    testee = ArrivalDepartureTimeViewModel(journeyTableViewModel: mockJourneyTableViewModel);
  });

  tearDown(() {
    testee.dispose();
    journeyStreamController.close();
    GetIt.I.reset();
  });

  test('wallclockTimeToMinuteValue_withFixedClock_shouldReturnFixedTime', () {
    final perseveranceTouchdown = Clock.fixed(DateTime(2021, 02, 18, 20, 55));
    withClock(perseveranceTouchdown, () {
      final actual = testee.wallclockTimeToMinuteValue;
      expect(actual, equals(perseveranceTouchdown.now()));
    });
  });

  test('wallclockTimeToMinute_withClockAtFixedOffset_shouldReturnFixedTimes', () {
    final curiosityTouchdown = DateTime(2012, 08, 06, 05, 17, 57);
    final testClock = Clock.fixed(curiosityTouchdown);
    final minuteRegister = <DateTime>[];
    fakeAsync((async) {
      withClock(testClock, () {
        testee.wallclockTimeToMinute.listen(minuteRegister.add);
        async.elapse(const Duration(minutes: 5));
        expect(minuteRegister, hasLength(1)); // only emits distinct values
        expect(minuteRegister.first, equals(curiosityTouchdown.roundDownToMinute));
      });
    });
  });

  test('showOperationalTimes_whenInitialized_thenReturnsTrue', () {
    expect(testee.showOperationalTimeValue, isTrue);
  });

  test('rxShowOperationalTime_whenJourneyIsNull_thenEmitsTrue', () async {
    journeyStreamController.add(null);
    await Future.delayed(Duration(milliseconds: 10));

    expect(await testee.showOperationalTime.first, isTrue);
  });

  test('rxShowOperationalTime_whenJourneyHasNoOperationalTimes_thenEmitsFalse', () async {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: false);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    await Future.delayed(Duration(milliseconds: 10));

    expect(await testee.showOperationalTime.first, isFalse);
  });

  test('rxShowOperationalTime_whenJourneyHasOperationalTimes_thenEmitsTrue', () async {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: true);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    await Future.delayed(Duration(milliseconds: 10));

    expect(await testee.showOperationalTime.first, isTrue);
  });

  test('toggleOperationalTime_whenJourneyHasCalculatedTimes_thenStartsTimerToSwitchBack', () async {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: true);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    await Future.delayed(Duration(milliseconds: 10));

    expect(testee.showOperationalTimeValue, isTrue);

    FakeAsync().run((fakeAsync) {
      testee.toggleOperationalTime();
      expect(testee.showOperationalTimeValue, isFalse);

      fakeAsync.elapse(Duration(seconds: 11));

      expect(testee.showOperationalTimeValue, isTrue);
    });
  });

  test('toggleOperationalTime_whenToggledBack_thenCancelsTimer', () async {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: true);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    await Future.delayed(Duration(milliseconds: 10));

    expect(testee.showOperationalTimeValue, isTrue);

    testee.toggleOperationalTime();
    expect(testee.showOperationalTimeValue, isFalse);

    FakeAsync().run((fakeAsync) {
      testee.toggleOperationalTime();
      expect(testee.showOperationalTimeValue, isTrue);

      fakeAsync.elapse(Duration(seconds: 11));

      expect(testee.showOperationalTimeValue, isTrue); // Should remain true
    });
  });

  test('toggleOperationalTime_whenJourneyHasNoCalculatedTimes_thenDoesNothing', () {
    final metadata = Metadata(anyOperationalArrivalDepartureTimes: false);
    final journey = Journey(metadata: metadata, data: []);

    journeyStreamController.add(journey);
    expect(testee.showOperationalTimeValue, isTrue);

    testee.toggleOperationalTime();
    expect(testee.showOperationalTimeValue, isTrue); // Should remain true
  });

  test('dispose_whenCalled_thenCancelsSubscriptionAndClosesSubject', () {
    expect(journeyStreamController.hasListener, isTrue);

    testee.dispose();

    expect(journeyStreamController.hasListener, isFalse);
  });
}
