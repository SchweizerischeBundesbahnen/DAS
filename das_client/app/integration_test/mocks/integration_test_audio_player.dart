import 'package:audioplayers/audioplayers.dart';

class IntegrationTestAudioPlayer extends AudioPlayer {
  @override
  Future<void> setReleaseMode(ReleaseMode releaseMode) async {
    if (releaseMode == ReleaseMode.loop) {
      // on android tester.pump() never completes while an audio is played
      super.setReleaseMode(ReleaseMode.release);
    } else {
      super.setReleaseMode(releaseMode);
    }
  }
}
