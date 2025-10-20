import 'package:app/di/di.dart';
import 'package:app/sound/sound.dart';
import 'package:app/widgets/assets.dart';
import 'package:audioplayers/audioplayers.dart';

class AdvisedSpeedStart extends Sound {
  const AdvisedSpeedStart();

  static const _volume = 1.0;

  @override
  Future<void> play() async {
    await Sound.volumeController.setVolume(_volume);
    final audioPlayer = DI.get<AudioPlayer>();
    await audioPlayer.stop();
    await audioPlayer.play(AssetSource(AppAssets.AdvisedSpeedStart));
  }
}
