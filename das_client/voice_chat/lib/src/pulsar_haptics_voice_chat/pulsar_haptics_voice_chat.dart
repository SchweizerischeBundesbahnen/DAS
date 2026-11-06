import 'dart:async';

import 'package:pulsar_haptics/pulsar_haptics.dart';

class PulsarHapticsVoiceChat {
  final _pulsar = Pulsar();

  Future<void> _play(Future<void> Function() action) async {
    await action();
  }

  Future<void> playPreset(String presetToBePlayed) {
    switch (presetToBePlayed) {
      case 'connect':
        return _play(_pulsar.presets.buzz);
      case 'disconnect':
        return _play(_pulsar.presets.wane);
      case 'mute':
        return _play(_pulsar.presets.stagger);
      case 'unmute':
        return _play(_pulsar.presets.spark);
      default:
        return Future.value();
    }
  }
}
