import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di/di.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:logging/logging.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:warnapp/component.dart';

import '../mocks/integration_test_audio_player.dart';
import '../mocks/mock_brightness_manager.dart';

final _log = Logger('E2ETestDASBaseScope');

class E2ETestDASBaseScope extends DASBaseScope {
  @override
  String get scopeName => 'E2ETestDASBaseScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerAppInfoAsync();
    _registerMockBrightnessManager();
    _registerIntegrationTestAudioPlayer();
    getIt.registerSounds();
    getIt.registerBattery();
    _registerMockMotionDataService();
    getIt.registerWarnapp();
    getIt.registerTimeConstants();
    getIt.registerUserSettings();
    getIt.registerConnectivityManager();
    getIt.registerLoginViewModel();
    getIt.registerAppLinksManager();
    getIt.registerLauncher();
    getIt.registerSferaLocalRepo();
    getIt.registerPreloadRepository();
    getIt.registerAppLifecycleViewModel();

    await getIt.allReady();
  }

  void _registerMockBrightnessManager() {
    getIt.registerLazySingleton<BrightnessManager>(() => MockBrightnessManager());
    getIt.registerLazySingleton<ScreenBrightness>(() => ScreenBrightness());
  }

  void _registerMockMotionDataService() {
    getIt.registerSingleton<MotionDataService>(
      WarnappComponent.createMockMotionDataService(samplingPeriod: Duration(milliseconds: 2)),
    );
  }

  void _registerIntegrationTestAudioPlayer() {
    getIt.registerLazySingleton<AudioPlayer>(
      () {
        _log.fine('Register IntegrationTestAudioPlayer');
        final audioPlayer = IntegrationTestAudioPlayer();
        // position updater leads to error in integration tests after widget dispose
        audioPlayer.positionUpdater = null;
        return audioPlayer;
      },
      dispose: (player) => player.dispose(),
    );
  }
}
