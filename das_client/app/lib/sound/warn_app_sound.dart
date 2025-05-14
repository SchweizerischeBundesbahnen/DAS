import 'package:app/di.dart';
import 'package:app/sound/sound.dart';
import 'package:app/widgets/assets.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:volume_controller/volume_controller.dart';

class WarnAppSound extends Sound {
  const WarnAppSound();

  static const _volume = 1.0;

  @override
  Future<void> play() async {
    await VolumeController.instance.setVolume(_volume);
    final audioPlayer = DI.get<AudioPlayer>();
    await audioPlayer.stop();
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
    await audioPlayer.play(AssetSource(AppAssets.warnappWarn));
  }
}
