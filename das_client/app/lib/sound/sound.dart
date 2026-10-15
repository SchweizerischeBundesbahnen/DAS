import 'package:app/di/di.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';
import 'package:volume_controller/volume_controller.dart';

abstract class const Sound() {
  static final _log = Logger('Sound');

  Future<void> play();

  static Future<void> stop() async {
    final audioPlayer = DI.get<AudioPlayer>();
    await audioPlayer.stop();
    await audioPlayer.setReleaseMode(ReleaseMode.release);
  }

  static Future<void> setVolume(double volume) async {
    try {
      await volumeController.setVolume(volume);
    } on MissingPluginException catch (err, st) {
      _log.warning('Skipping sound volume update because the volume controller plugin is unavailable.', err, st);
    } on PlatformException catch (err, st) {
      if (err.code != 'SetVolumeError') rethrow;
      _log.warning('Skipping sound volume update because the system volume slider is unavailable.', err, st);
    }
  }

  static VolumeController get volumeController => VolumeController.instance..showSystemUI = false;
}
