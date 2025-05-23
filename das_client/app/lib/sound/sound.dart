import 'package:app/di.dart';
import 'package:audioplayers/audioplayers.dart';

abstract class Sound {
  const Sound();

  Future<void> play();

  static Future<void> stop() async {
    final audioPlayer = DI.get<AudioPlayer>();
    await audioPlayer.stop();
    await audioPlayer.setReleaseMode(ReleaseMode.release);
  }
}
