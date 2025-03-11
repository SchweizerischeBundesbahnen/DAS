import 'package:audioplayers/audioplayers.dart';
import 'package:das_client/di.dart';
import 'package:volume_controller/volume_controller.dart';

class Sound {
  const Sound._();

  static const _defaultVolume = 0.5;

  static Future<void> play(String soundAsset, {double? volume}) async {
    await VolumeController.instance.setVolume(volume ?? _defaultVolume);
    await DI.get<AudioPlayer>().stop();
    await DI.get<AudioPlayer>().play(AssetSource(soundAsset));
  }
}
