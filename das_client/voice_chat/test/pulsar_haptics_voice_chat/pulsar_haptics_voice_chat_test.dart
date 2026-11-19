import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:pulsar_haptics/pulsar_haptics.dart';
import 'package:voice_chat/component.dart';

void main() {
  late PulsarPlatform originalPlatform;
  late _TestPulsarPlatform platform;
  late PulsarHapticsVoiceChat testee;

  setUp(() {
    originalPlatform = PulsarPlatform.instance;
    platform = _TestPulsarPlatform();
    PulsarPlatform.instance = platform;
    testee = PulsarHapticsVoiceChat();
  });

  tearDown(() {
    PulsarPlatform.instance = originalPlatform;
  });

  for (final (event, preset) in [
    ('connect', 'buzz'),
    ('disconnect', 'wane'),
    ('mute', 'stagger'),
    ('unmute', 'spark'),
  ]) {
    test('playPreset_whenEventIs${event}_thenPlays$preset', () async {
      // GIVEN

      // WHEN
      await testee.playPreset(event);

      // THEN
      expect(platform.playedPresets, [preset]);
    });
  }

  test('playPreset_whenEventIsUnknown_thenDoesNotPlay', () async {
    // GIVEN

    // WHEN
    await testee.playPreset('unknown');

    // THEN
    expect(platform.playedPresets, isEmpty);
  });

  test('playPreset_whenPlaybackFails_thenPropagatesError', () async {
    // GIVEN
    final error = StateError('Playback failed');
    platform.playback = Future.error(error);

    // WHEN / THEN
    await expectLater(testee.playPreset('connect'), throwsA(same(error)));
  });

  test('playPreset_whenPlaybackIsPending_thenWaitsForPlayback', () async {
    // GIVEN
    final playback = Completer<void>();
    platform.playback = playback.future;
    var completed = false;

    // WHEN
    final result = testee.playPreset('connect').then((_) => completed = true);
    await Future<void>.value();

    // THEN
    expect(completed, isFalse);
    playback.complete();
    await result;
    expect(completed, isTrue);
  });
}

class _TestPulsarPlatform extends PulsarPlatform {
  final playedPresets = <String>[];
  Future<void>? playback;

  @override
  Future<void> play(String name) {
    playedPresets.add(name);
    return playback ?? Future.value();
  }
}
