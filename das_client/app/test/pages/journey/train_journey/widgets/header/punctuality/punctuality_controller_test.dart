import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_state_enum.dart';
import 'package:app/util/time_constants.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:sfera/component.dart';

void main() {
  setUp(() {
    GetIt.I.registerSingleton(TimeConstants());
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Clock buildFakeClock(DateTime baseTime, FakeAsync fakeAsync) {
    return Clock(() => baseTime.add(fakeAsync.elapsed));
  }

  test('test default state is visible', () async {
    final testee = PunctualityController();
    final completer = Completer<PunctualityState>();

    testee.punctualityStateStream.listen((state) {
      if (!completer.isCompleted) completer.complete(state);
    });

    final state = await completer.future;
    expect(state, PunctualityState.visible);
  });

  test('test check if punctuality display goes from visible to stale to hidden', () {
    FakeAsync().run((fakeAsync) {
      final fakeClock = buildFakeClock(DateTime(2025), fakeAsync);

      withClock(fakeClock, () {
        final testee = PunctualityController();
        late PunctualityState latest;

        testee.punctualityStateStream.listen((state) {
          latest = state;
        });

        testee.startMonitoring();

        final delay = Delay(delay: const Duration(minutes: 1, seconds: 3), location: 'Bern');
        testee.updatePunctualityTimestamp(delay);

        fakeAsync.elapse(const Duration(seconds: 100));
        expect(latest, PunctualityState.visible);

        fakeAsync.elapse(const Duration(seconds: 100));
        expect(latest, PunctualityState.stale);

        fakeAsync.elapse(const Duration(seconds: 200));
        expect(latest, PunctualityState.hidden);

        testee.stopMonitoring();
      });
    });
  });

  test('test check if punctuality process triggers after a new update', () {
    FakeAsync().run((fakeAsync) {
      final fakeClock = buildFakeClock(DateTime(2025), fakeAsync);

      withClock(fakeClock, () {
        final testee = PunctualityController();
        late PunctualityState latest;

        testee.punctualityStateStream.listen((state) {
          latest = state;
        });

        testee.startMonitoring();

        final delay1 = Delay(delay: const Duration(seconds: 1), location: 'Zürich');
        testee.updatePunctualityTimestamp(delay1);
        fakeAsync.elapse(const Duration(seconds: 50));
        expect(latest, PunctualityState.visible);

        final delay2 = Delay(delay: const Duration(minutes: 1, seconds: 34), location: 'Bern');
        testee.updatePunctualityTimestamp(delay2);
        fakeAsync.elapse(const Duration(seconds: 60));
        expect(latest, PunctualityState.visible);

        testee.stopMonitoring();
      });
    });
  });

  test('test check if same value delays do not trigger the punctuality process when the same location is given', () {
    FakeAsync().run((fakeAsync) {
      final fakeClock = buildFakeClock(DateTime(2025), fakeAsync);

      late PunctualityState latest;

      withClock(fakeClock, () {
        final testee = PunctualityController();

        testee.punctualityStateStream.listen((state) {
          latest = state;
        });

        testee.startMonitoring();

        testee.updatePunctualityTimestamp(Delay(delay: const Duration(minutes: 2, seconds: 14), location: 'Bern'));
        fakeAsync.elapse(const Duration(seconds: 1));
        expect(latest, PunctualityState.visible);

        testee.updatePunctualityTimestamp(Delay(delay: const Duration(minutes: 2, seconds: 14), location: 'Bern'));
        fakeAsync.elapse(const Duration(seconds: 100));
        expect(latest, PunctualityState.visible);

        testee.updatePunctualityTimestamp(Delay(delay: const Duration(minutes: 2, seconds: 14), location: 'Bern'));
        fakeAsync.elapse(const Duration(seconds: 100));
        expect(latest, PunctualityState.stale);

        testee.updatePunctualityTimestamp(Delay(delay: const Duration(minutes: 2, seconds: 14), location: 'Bern'));
        fakeAsync.elapse(const Duration(seconds: 200));
        expect(latest, PunctualityState.hidden);

        testee.stopMonitoring();
      });
    });
  });
}
