import 'package:app/di.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';

class Sound {
  const Sound._();

  static const _defaultVolume = 0.5;

  static Future<void> play(String soundAsset, {double? volume, bool? loop}) async {
    await VolumeController.instance.setVolume(volume ?? _defaultVolume);
    final audioPlayer = DI.get<AudioPlayer>();
    await audioPlayer.stop();
    await audioPlayer.setReleaseMode(
      loop == true ? ReleaseMode.loop : ReleaseMode.release,
    );
    await audioPlayer.play(AssetSource(soundAsset));
  }

  static Future<void> stop() async {
    final audioPlayer = DI.get<AudioPlayer>();
    await audioPlayer.stop();
    await audioPlayer.setReleaseMode(ReleaseMode.release);
  }
}
