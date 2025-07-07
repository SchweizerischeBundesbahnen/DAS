import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_state_enum.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:collection/collection.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sfera/component.dart';

void main() {
  const timeConstants = TimeConstants();
  late PunctualityViewModel testee;
  late StreamController<Journey?> journeyController;
  late StreamSubscription subscrption;
  late List<dynamic> emitRegister;
  late FakeAsync testAsync;

  final delayButNoCalculatedSpeedJourney = Journey(
    metadata: Metadata(
      delay: Delay(delay: Duration(seconds: 10), location: 'Bern'),
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
      delay: Delay(delay: Duration(seconds: 10), location: 'Bern'),
      lastServicePoint: ServicePoint(
        name: 'Point 1',
        calculatedSpeed: SingleSpeed(value: '100'),
        order: 0,
        kilometre: [],
      ),
    ),
    data: [],
  );

  setUp(() {
    GetIt.I.registerSingleton<TimeConstants>(timeConstants);
    fakeAsync((fakeAsync) {
      journeyController = StreamController<Journey?>();
      testAsync = fakeAsync;
      testee = PunctualityViewModel(journeyStream: journeyController.stream);
      emitRegister = <dynamic>[];
      subscrption = testee.punctualityState.listen(emitRegister.add);
      _processStreamInFakeAsync(fakeAsync);
    });
  });

  tearDown(() {
    subscrption.cancel();
    testee.dispose();
    journeyController.close();
    GetIt.I.reset();
  });

  test('punctualityStateValue_whenNoStateAdded_IsHiddenByDefault', () {
    expect(testee.punctualityStateValue, PunctualityState.hidden);
  });

  test('punctualityStateValue_whenJourneyUpdateWithNull_thenStaysHiddenAndNeverEmits', () async {
    // ARRANGE
    expect(emitRegister.first, PunctualityState.hidden);
    emitRegister.clear();

    // ACT
    testAsync.run((_) => journeyController.add(null));
    _processStreamInFakeAsync(testAsync);

    // EXPECT
    expect(emitRegister, hasLength(0));
    expect(testee.punctualityStateValue, PunctualityState.hidden);
  });

  group('journey with delay but no speeds', () {
    setUp(() {
      testAsync.run((_) {
        emitRegister.clear();

        journeyController.add(delayButNoCalculatedSpeedJourney);
        _processStreamInFakeAsync(testAsync);
      });
    });

    test('punctualityStateValue_whenJourneyWithoutSpeeds_staysHiddenAndDoesNotEmit', () {
      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.punctualityStateValue, PunctualityState.hidden);
    });

    test('punctualityStateValue_whenStaleTimeIsElapsedAndNoCalculatedSpeeds_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.punctualityStateValue, PunctualityState.hidden);
    });

    test('punctualityStateValue_whenDisappearTimeIsElapsedAndNoCalculatedSpeeds_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityDisappearSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.punctualityStateValue, PunctualityState.hidden);
    });
  });

  group('journey with delay and advised speeds', () {
    setUp(() {
      testAsync.run((_) {
        emitRegister.clear();
        journeyController.add(delayAndCalculatedSpeedJourney);
        _processStreamInFakeAsync(testAsync);
      });
    });

    test('punctualityStateValue_whenJourneyWithSpeedsAndDelay_isVisibleAndEmitsOnce', () {
      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(emitRegister.first, PunctualityState.visible);
      expect(testee.punctualityStateValue, PunctualityState.visible);
    });

    test('punctualityStateValue_whenStaleTimeIsElapsed_emitsStaleState', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityState.visible);
      emitRegister.clear();

      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(testee.punctualityStateValue, PunctualityState.stale);
    });

    test('punctualityStateValue_whenDisappearTimeIsElapsed_emitsStaleThenHiddenState', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityState.visible);
      emitRegister.clear();

      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityDisappearSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(ListEquality().equals([PunctualityState.stale, PunctualityState.hidden], emitRegister), isTrue);
      expect(testee.punctualityStateValue, PunctualityState.hidden);
    });

    test('punctualityState_whenJourneyUpdateWithNull_emitsNothing', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityState.visible);
      emitRegister.clear();
      testAsync.run((_) => journeyController.add(null));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.punctualityStateValue, PunctualityState.visible);
    });

    test('punctualityState_whenJourneyUpdateWithNoCalculatedSpeed_emitsHidden', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityState.visible);
      emitRegister.clear();
      testAsync.run((_) => journeyController.add(delayButNoCalculatedSpeedJourney));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(testee.punctualityStateValue, PunctualityState.hidden);
    });

    test('punctualityState_whenJourneyWithSameDelayIsGiven_doesNotResetTimers', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityState.visible);
      emitRegister.clear();
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds ~/ 2));
      expect(testee.punctualityStateValue, PunctualityState.visible);

      // ACT
      testAsync.run((_) => journeyController.add(delayAndCalculatedSpeedJourney));
      testAsync.elapse(Duration(seconds: (timeConstants.punctualityStaleSeconds ~/ 2) + 1));

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(testee.punctualityStateValue, PunctualityState.stale);
    });
  });
}

void _processStreamInFakeAsync(FakeAsync testAsync) => testAsync.elapse(Duration.zero);
