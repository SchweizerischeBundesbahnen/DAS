import 'dart:async';
import 'dart:collection';

import 'package:app/pages/journey/train_journey/widgets/chronograph/chronograph_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/chronograph/punctuality_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:sfera/component.dart';

void main() {
  const timeConstants = TimeConstants();
  const testDelayString = '+00:10';
  late Clock testClock;
  late ChronographViewModel testee;
  late StreamController<Journey?> journeyController;
  late StreamSubscription punctualitySubscription;
  late StreamSubscription formattedWallclockTimeSubscription;
  late List<PunctualityModel> punctualityEmitRegister;
  late List<String> formattedWallclockTimeRegister;
  late FakeAsync testAsync;

  final delayButNoCalculatedSpeedJourney = Journey(
    metadata: Metadata(
      delay: Delay(value: Duration(seconds: 10), location: 'Bern'),
      lastServicePoint: ServicePoint(
        name: 'Point 1',
        order: 0,
        kilometre: [],
      ),
    ),
    data: [],
  );

  final delayAndCalculatedSpeedJourney = Journey(
    metadata: Metadata(
      delay: Delay(value: Duration(seconds: 10), location: 'Bern'),
      lastServicePoint: ServicePoint(
        name: 'Point 1',
        order: 0,
        kilometre: [],
      ),
      calculatedSpeeds: SplayTreeMap.of({0: SingleSpeed(value: '100')}),
    ),
    data: [],
  );

  setUp(() {
    GetIt.I.registerSingleton<TimeConstants>(timeConstants);
    testClock = Clock.fixed(clock.now());
    fakeAsync((fakeAsync) {
      journeyController = StreamController<Journey?>();
      testAsync = fakeAsync;
      formattedWallclockTimeRegister = <String>[];
      withClock(testClock, () {
        testee = ChronographViewModel(journeyStream: journeyController.stream);
        formattedWallclockTimeSubscription = testee.formattedWallclockTime.listen(formattedWallclockTimeRegister.add);
      });
      punctualityEmitRegister = <PunctualityModel>[];
      punctualitySubscription = testee.punctualityModel.listen(punctualityEmitRegister.add);
      _processStreamInFakeAsync(fakeAsync);
    });
  });

  tearDown(() {
    punctualitySubscription.cancel();
    formattedWallclockTimeSubscription.cancel();
    testee.dispose();
    journeyController.close();
    GetIt.I.reset();
  });

  test('formattedWallClockTimeValue_withFixedTime_shouldReturnFixedTime', () {
    final apolloElevenTouchdown = Clock.fixed(DateTime(1969, 07, 20, 2, 56, 0));
    withClock(apolloElevenTouchdown, () {
      final actual = testee.formattedWallclockTimeValue;
      expect(actual, equals('02:56:00'));
    });
  });

  test('formattedWallClockTime_withFixedTime_shouldEmitFixedFormattedTimes', () {
    testAsync.elapse(const Duration(seconds: 1));
    expect(formattedWallclockTimeRegister, isNotEmpty);
    expect(formattedWallclockTimeRegister.first, equals(DateFormat('HH:mm:ss').format(testClock.now())));
  });

  test('punctualityModelValue_whenNoStateAdded_IsHiddenByDefault', () {
    expect(testee.punctualityModelValue, PunctualityModel.hidden());
  });

  test('punctualityModelValue_whenJourneyUpdateWithNull_thenStaysHiddenAndNeverEmits', () async {
    // ARRANGE
    expect(punctualityEmitRegister.first, equals(PunctualityModel.hidden()));
    punctualityEmitRegister.clear();

    // ACT
    testAsync.run((_) => journeyController.add(null));
    _processStreamInFakeAsync(testAsync);

    // EXPECT
    expect(punctualityEmitRegister, hasLength(0));
    expect(testee.punctualityModelValue, equals(PunctualityModel.hidden()));
  });

  group('journey with delay but no speeds', () {
    setUp(() {
      testAsync.run((_) {
        punctualityEmitRegister.clear();

        journeyController.add(delayButNoCalculatedSpeedJourney);
        _processStreamInFakeAsync(testAsync);
      });
    });

    test('punctualityModelValue_whenJourneyWithoutSpeeds_staysHiddenAndDoesNotEmit', () {
      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, PunctualityModel.hidden());
    });

    test('punctualityModelValue_whenStaleTimeIsElapsedAndNoCalculatedSpeeds_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds + 1));

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, PunctualityModel.hidden());
    });

    test('punctualityModelValue_whenDisappearTimeIsElapsedAndNoCalculatedSpeeds_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityDisappearSeconds + 1));

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, PunctualityModel.hidden());
    });
  });

  group('journey with delay and advised speeds', () {
    setUp(() {
      testAsync.run((_) {
        punctualityEmitRegister.clear();
        journeyController.add(delayAndCalculatedSpeedJourney);
        _processStreamInFakeAsync(testAsync);
      });
    });

    test('punctualityModelValue_whenJourneyWithSpeedsAndDelay_isVisibleAndEmitsOnce', () {
      // EXPECT
      expect(punctualityEmitRegister, hasLength(1));
      expect(punctualityEmitRegister.first, PunctualityModel.visible(delay: testDelayString));
      expect(testee.punctualityModelValue, PunctualityModel.visible(delay: testDelayString));
    });

    test('punctualityModelValue_whenStaleTimeIsElapsed_emitsStaleState', () {
      // ARRANGE
      expect(punctualityEmitRegister.first, PunctualityModel.visible(delay: testDelayString));
      punctualityEmitRegister.clear();

      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds + 1));

      // EXPECT
      expect(punctualityEmitRegister, hasLength(1));
      expect(testee.punctualityModelValue, PunctualityModel.stale(delay: testDelayString));
    });

    test('punctualityModelValue_whenDisappearTimeIsElapsed_emitsStaleThenHiddenState', () {
      // ARRANGE
      expect(punctualityEmitRegister.first, PunctualityModel.visible(delay: testDelayString));
      punctualityEmitRegister.clear();

      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityDisappearSeconds + 1));

      // EXPECT
      expect(punctualityEmitRegister, hasLength(2));
      expect(
        ListEquality().equals([
          PunctualityModel.stale(delay: testDelayString),
          PunctualityModel.hidden(),
        ], punctualityEmitRegister),
        isTrue,
      );
      expect(testee.punctualityModelValue, PunctualityModel.hidden());
    });

    test('punctualityState_whenJourneyUpdateWithNull_emitsNothing', () {
      // ARRANGE
      expect(punctualityEmitRegister.first, PunctualityModel.visible(delay: testDelayString));
      punctualityEmitRegister.clear();
      testAsync.run((_) => journeyController.add(null));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(0));
      expect(testee.punctualityModelValue, PunctualityModel.visible(delay: testDelayString));
    });

    test('punctualityState_whenJourneyUpdateWithNoCalculatedSpeed_emitsHidden', () {
      // ARRANGE
      expect(punctualityEmitRegister.first, PunctualityModel.visible(delay: testDelayString));
      punctualityEmitRegister.clear();
      testAsync.run((_) => journeyController.add(delayButNoCalculatedSpeedJourney));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(punctualityEmitRegister, hasLength(1));
      expect(testee.punctualityModelValue, PunctualityModel.hidden());
    });

    test('punctualityState_whenJourneyWithSameDelayIsGiven_doesNotResetTimers', () {
      // ARRANGE
      expect(punctualityEmitRegister.first, PunctualityModel.visible(delay: testDelayString));
      punctualityEmitRegister.clear();
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds ~/ 2));
      expect(testee.punctualityModelValue, PunctualityModel.visible(delay: testDelayString));

      // ACT
      testAsync.run((_) => journeyController.add(delayAndCalculatedSpeedJourney));
      testAsync.elapse(Duration(seconds: (timeConstants.punctualityStaleSeconds ~/ 2) + 1));

      // EXPECT
      expect(punctualityEmitRegister, hasLength(1));
      expect(testee.punctualityModelValue, PunctualityModel.stale(delay: testDelayString));
    });
  });
}

void _processStreamInFakeAsync(FakeAsync testAsync) => testAsync.elapse(Duration.zero);
