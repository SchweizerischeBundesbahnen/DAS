import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di/di.dart';
import 'package:app/di/scopes/das_base_scope.dart';
import 'package:app/pages/settings/user_settings.dart';
import 'package:app/util/time_constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_x/component.dart';
import 'package:logging/logging.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:warnapp/component.dart';

import '../util/test_time_constants.dart';
import 'integration_test_audio_player.dart';
import 'mock_battery.dart';
import 'mock_brightness_manager.dart';
import 'mock_connectivity_manager.dart';
import 'mock_user_settings.dart';

final _log = Logger('MockDASBaseScope');

class MockDASBaseScope extends DASBaseScope {
  @override
  String get scopeName => 'DASBaseScopeMock';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
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
    // TODO: maybe use mock manager to integration test links?
    getIt.registerAppLinksManager();

    await getIt.allReady();
  }

  void _registerMockBattery() {
    getIt.registerSingletonAsync<Battery>(() async => MockBattery());
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
}
