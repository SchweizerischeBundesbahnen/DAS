import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di/di.dart';
import 'package:app/di/scopes/das_base_scope.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:fimber/fimber.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:warnapp/component.dart';

import 'battery_mock.dart';
import 'brightness_mock.dart';

class MockDASBaseScope extends DASBaseScope {
  @override
  String get scopeName => 'DASBaseScopeMock';

  @override
  Future<void> push() async {
    Fimber.d('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    _registerMockBrightnessManager();
    getIt.registerAudioPlayer();
    _registerMockBattery();
    _registerMockMotionDataService();
    getIt.registerWarnapp();

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
}
