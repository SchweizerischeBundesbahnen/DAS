import 'package:app/di/di.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';

abstract class Sound {
  const Sound();

  Future<void> play();

  static Future<void> stop() async {
    final audioPlayer = DI.get<AudioPlayer>();
    await audioPlayer.stop();
    await audioPlayer.setReleaseMode(ReleaseMode.release);
  }

  static VolumeController get volumeController => VolumeController.instance..showSystemUI = false;
}
