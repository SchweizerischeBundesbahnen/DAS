import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_model.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_view_model.dart';
import 'package:app/util/time_constants.dart';
import 'package:collection/collection.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sfera/component.dart';

void main() {
  const timeConstants = TimeConstants();
  const testDelayString = '+00:10';
  late PunctualityViewModel testee;
  late StreamController<Journey?> journeyController;
  late StreamSubscription subscription;
  late List<PunctualityModel> emitRegister;
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
      emitRegister = <PunctualityModel>[];
      subscription = testee.model.listen(emitRegister.add);
      _processStreamInFakeAsync(fakeAsync);
    });
  });

  tearDown(() {
    subscription.cancel();
    testee.dispose();
    journeyController.close();
    GetIt.I.reset();
  });

  test('punctualityStateValue_whenNoStateAdded_IsHiddenByDefault', () {
    expect(testee.modelValue, PunctualityModel.hidden());
  });

  test('punctualityStateValue_whenJourneyUpdateWithNull_thenStaysHiddenAndNeverEmits', () async {
    // ARRANGE
    expect(emitRegister.first, equals(PunctualityModel.hidden()));
    emitRegister.clear();

    // ACT
    testAsync.run((_) => journeyController.add(null));
    _processStreamInFakeAsync(testAsync);

    // EXPECT
    expect(emitRegister, hasLength(0));
    expect(testee.modelValue, equals(PunctualityModel.hidden()));
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
      expect(testee.modelValue, PunctualityModel.hidden());
    });

    test('punctualityStateValue_whenStaleTimeIsElapsedAndNoCalculatedSpeeds_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.modelValue, PunctualityModel.hidden());
    });

    test('punctualityStateValue_whenDisappearTimeIsElapsedAndNoCalculatedSpeeds_staysHiddenAndDoesNotEmit', () {
      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityDisappearSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.modelValue, PunctualityModel.hidden());
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
      expect(emitRegister.first, PunctualityModel.visible(delay: testDelayString));
      expect(testee.modelValue, PunctualityModel.visible(delay: testDelayString));
    });

    test('punctualityStateValue_whenStaleTimeIsElapsed_emitsStaleState', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityModel.visible(delay: testDelayString));
      emitRegister.clear();

      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(testee.modelValue, PunctualityModel.stale(delay: testDelayString));
    });

    test('punctualityStateValue_whenDisappearTimeIsElapsed_emitsStaleThenHiddenState', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityModel.visible(delay: testDelayString));
      emitRegister.clear();

      // ACT
      testAsync.elapse(Duration(seconds: timeConstants.punctualityDisappearSeconds + 1));

      // EXPECT
      expect(emitRegister, hasLength(2));
      expect(
        ListEquality().equals([
          PunctualityModel.stale(delay: testDelayString),
          PunctualityModel.hidden(),
        ], emitRegister),
        isTrue,
      );
      expect(testee.modelValue, PunctualityModel.hidden());
    });

    test('punctualityState_whenJourneyUpdateWithNull_emitsNothing', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityModel.visible(delay: testDelayString));
      emitRegister.clear();
      testAsync.run((_) => journeyController.add(null));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(emitRegister, hasLength(0));
      expect(testee.modelValue, PunctualityModel.visible(delay: testDelayString));
    });

    test('punctualityState_whenJourneyUpdateWithNoCalculatedSpeed_emitsHidden', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityModel.visible(delay: testDelayString));
      emitRegister.clear();
      testAsync.run((_) => journeyController.add(delayButNoCalculatedSpeedJourney));
      _processStreamInFakeAsync(testAsync);

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(testee.modelValue, PunctualityModel.hidden());
    });

    test('punctualityState_whenJourneyWithSameDelayIsGiven_doesNotResetTimers', () {
      // ARRANGE
      expect(emitRegister.first, PunctualityModel.visible(delay: testDelayString));
      emitRegister.clear();
      testAsync.elapse(Duration(seconds: timeConstants.punctualityStaleSeconds ~/ 2));
      expect(testee.modelValue, PunctualityModel.visible(delay: testDelayString));

      // ACT
      testAsync.run((_) => journeyController.add(delayAndCalculatedSpeedJourney));
      testAsync.elapse(Duration(seconds: (timeConstants.punctualityStaleSeconds ~/ 2) + 1));

      // EXPECT
      expect(emitRegister, hasLength(1));
      expect(testee.modelValue, PunctualityModel.stale(delay: testDelayString));
    });
  });
}

void _processStreamInFakeAsync(FakeAsync testAsync) => testAsync.elapse(Duration.zero);
