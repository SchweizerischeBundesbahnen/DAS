import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di/di.dart';
import 'package:app/di/scopes/das_base_scope.dart';
import 'package:app/util/time_constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:logging/logging.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:warnapp/component.dart';

import '../util/test_time_constants.dart';
import 'integration_test_audio_player.dart';
import 'mock_battery.dart';
import 'mock_brightness_manager.dart';

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
    _registerMockBattery();
    _registerMockMotionDataService();
    getIt.registerWarnapp();
    _registerTestTimeConstants();

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
    getIt.registerLazySingleton<AudioPlayer>(() {
      _log.fine('Register IntegrationTestAudioPlayer');
      return IntegrationTestAudioPlayer();
    });
  }

  void _registerTestTimeConstants() {
    getIt.registerSingleton<TimeConstants>(TestTimeConstants());
  }
}
