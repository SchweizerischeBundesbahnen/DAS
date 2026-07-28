import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di/di.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/provider/user_settings.dart';
import 'package:app/util/time_constants.dart';
import 'package:app_links_x/component.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_x/component.dart';
import 'package:logging/logging.dart';
import 'package:preload/component.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:warnapp/component.dart';

import '../mocks/integration_test_audio_player.dart';
import '../mocks/mock_app_links_manager.dart';
import '../mocks/mock_battery.dart';
import '../mocks/mock_brightness_manager.dart';
import '../mocks/mock_connectivity_manager.dart';
import '../mocks/mock_launcher.dart';
import '../mocks/mock_preload_repository.dart';
import '../mocks/mock_user_settings.dart';
import '../util/test_time_constants.dart';

final _log = Logger('IntegrationTestDASBaseScope');

class IntegrationTestDASBaseScope extends DASBaseScope {
  @override
  String get scopeName => 'IntegrationTestDASBaseScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing integration test scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerAppInfoAsync();
    _registerMockBrightnessManager();
    _registerIntegrationTestAudioPlayer();
    getIt.registerSounds();
    _registerMockBattery();
    _registerMockMotionDataService();
    getIt.registerWarnapp();
    _registerTestTimeConstants();
    _registerUserSettings();
    _registerMockConnectivityManager();
    getIt.registerLoginViewModel();
    _registerMockAppLinksManager();
    _registerMockLauncher();
    getIt.registerSferaLocalRepo();
    getIt.registerAppLifecycleViewModel();

    _registerMockPreloadRepository();

    await getIt.allReady();
  }

  void _registerMockAppLinksManager() {
    getIt.registerLazySingleton<AppLinksManager>(() => MockAppLinksManager());
  }

  void _registerMockBattery() {
    getIt.registerSingleton<Battery>(MockBattery());
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

  void _registerTestTimeConstants() {
    getIt.registerSingleton<TimeConstants>(TestTimeConstants());
  }

  void _registerUserSettings() {
    getIt.registerSingleton<UserSettings>(MockUserSettings());
  }

  void _registerMockConnectivityManager() {
    getIt.registerSingleton<ConnectivityManager>(MockConnectivityManager());
  }

  void _registerMockLauncher() {
    getIt.registerSingleton<Launcher>(MockLauncher(userSettings: DI.get(), flavor: DI.get()));
  }

  void _registerMockPreloadRepository() {
    getIt.registerSingleton<PreloadRepository>(MockPreloadRepository());
  }
}
