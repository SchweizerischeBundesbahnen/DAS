import 'package:app/brightness/brightness_manager.dart';
import 'package:app/brightness/brightness_manager_impl.dart';
import 'package:app/di/di.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:app/provider/user_settings.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/util/time_constants.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:connectivity_x/component.dart';
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
    getIt.registerSounds();
    getIt.registerBattery();
    getIt.registerMotionDataService();
    getIt.registerWarnapp();
    getIt.registerTimeConstants();
    getIt.registerUserSettings();
    getIt.registerConnectivityManager();
    getIt.registerLoginViewModel();
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
    registerLazySingleton<AudioPlayer>(
      () {
        _log.fine('Register AudioPlayer');
        return AudioPlayer();
      },
      dispose: (player) => player.dispose(),
    );
  }

  void registerSounds() {
    _log.fine('Register DASSounds');
    registerSingleton<DASSounds>(DASSounds());
  }

  void registerMotionDataService() {
    _log.fine('Register MotionDataServce');
    registerSingleton(WarnappComponent.createDeviceMotionDataService());
  }

  void registerWarnapp() {
    _log.fine('Register WarnApp');
    registerSingleton(WarnappComponent.createWarnappRepository(motionDataService: DI.get()));
  }

  void registerTimeConstants() {
    _log.fine('Register TimeConstants');
    registerSingleton<TimeConstants>(TimeConstants());
  }

  void registerUserSettings() {
    _log.fine('Register UserSettings');
    registerSingleton<UserSettings>(UserSettings());
  }

  void registerConnectivityManager() {
    _log.fine('Register ConnectivityManager');
    registerSingleton<ConnectivityManager>(ConnectivityComponent.connectivityManager());
  }

  void registerLoginViewModel() {
    _log.fine('Register LoginViewModel');
    registerSingleton<LoginViewModel>(LoginViewModel(), dispose: (vm) => vm.dispose());
  }
}
