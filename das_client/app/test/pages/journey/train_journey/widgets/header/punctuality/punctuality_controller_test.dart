import 'dart:async';

import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_controller.dart';
import 'package:app/pages/journey/train_journey/widgets/punctuality/punctuality_state_enum.dart';
import 'package:clock/clock.dart';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfera/component.dart';

void main() {
  Future<PunctualityState> listenToStream(PunctualityController testee) {
    final completer = Completer<PunctualityState>();

    testee.punctualityStateStream.listen(
      expectAsync1((event) {
        completer.complete(event);
      }),
    );

    return completer.future;
  }

  test('test default state is visible', () async {
    final testee = PunctualityController();
    final state = await listenToStream(testee);
    expect(state, PunctualityState.visible);
  });

  //TODO fakeasync using, gang i controller generier es delay und monitoring starte, 100' sec passe la luege ob state changed etc

  test('test check if punctuality display works like normal', () {
    FakeAsync().run((fakeAsync) async {
      final baseTime = DateTime(2025);
      final testee = PunctualityController();
      final now = baseTime.add(fakeAsync.elapsed);
      testee.startMonitoring();

      late PunctualityState latest;
      testee.punctualityStateStream.listen((state) {
        latest = state;
      });

      //TODO Still add the rest of the body so the check about visible, stale, hidden

      testee.stopMonitoring();
    });
  });

  //TODO monitoring starte, 50 sek abwarte u ner nöie update när nomau iwie 60 sek skippe

  test('test check if punctuality process triggers after a new update', () {});

  test('test check if same value delays still triggers the punctuality process', () {
    FakeAsync().run((fakeAsync) {
      final baseTime = DateTime(2025);
      final testee = PunctualityController();
      final now = baseTime.add(fakeAsync.elapsed);
      testee.startMonitoring();

      late PunctualityState latest;
      testee.punctualityStateStream.listen((state) {
        latest = state;
      });

      for (var i = 0; i < 3; i++) {
        withClock(Clock.fixed(now), () {
          final delay = Delay(delay: Duration(minutes: 2, seconds: 14), location: 'Bern');
          testee.updatePunctualityTimestamp(delay);
        });
        fakeAsync.elapse(const Duration(seconds: 100));
      }

      fakeAsync.elapse(const Duration(seconds: 400));
      withClock(Clock.fixed(now), () {
        expect(latest, PunctualityState.hidden);
      });

      testee.stopMonitoring();
    });
  });
}
