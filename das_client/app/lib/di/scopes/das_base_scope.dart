import 'package:app/brightness/brightness_manager.dart';
import 'package:app/brightness/brightness_manager_impl.dart';
import 'package:app/di/di.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:warnapp/component.dart';

final _log = Logger('DASBaseScope');

/// Named 'DASBaseScope' to avoid confusion with GetIt's 'baseScope'.
class DASBaseScope extends DIScope {
  @override
  String get scopeName => 'DASBaseScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    getIt.registerBrightnessManager();
    getIt.registerAudioPlayer();
    getIt.registerBattery();
    getIt.registerMotionDataService();
    getIt.registerWarnapp();
    await getIt.allReady();
  }
}

extension BaseScopeExtension on GetIt {
  void registerBrightnessManager() {
    _log.fine('Register ScreenBrightness');
    registerSingleton<ScreenBrightness>(ScreenBrightness());

    _log.fine('Register BrightnessManager');
    registerSingleton<BrightnessManager>(BrightnessManagerImpl(DI.get<ScreenBrightness>()));
  }

  void registerBattery() {
    _log.fine('Register Battery');
    registerSingleton<Battery>(Battery());
  }

  void registerAudioPlayer() {
    registerLazySingleton<AudioPlayer>(() {
      _log.fine('Register AudioPlayer');
      return AudioPlayer();
    });
  }

  void registerMotionDataService() {
    registerSingleton(WarnappComponent.createDeviceMotionDataService());
  }

  void registerWarnapp() {
    registerSingleton(WarnappComponent.createWarnappRepository(motionDataService: DI.get()));
  }
}
