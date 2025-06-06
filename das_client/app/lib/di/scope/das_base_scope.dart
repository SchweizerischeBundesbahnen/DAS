import 'package:app/brightness/brightness_manager.dart';
import 'package:app/brightness/brightness_manager_impl.dart';
import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:app/util/device_id_info.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/component.dart';
import 'package:screen_brightness/screen_brightness.dart';

// Named 'DASBaseScope' to avoid confusion with GetIt's 'baseScope'.
class DASBaseScope {
  DASBaseScope._();

  static const String _scopeName = 'DASBaseScope';
  static final _getIt = GetIt.I;

  static Future<void> push({required Flavor flavor}) {
    Fimber.d('Pushing scope $_scopeName');
    _getIt.pushNewScope(scopeName: _scopeName);
    _getIt.registerFlavor(flavor);
    _getIt.registerBrightnessManager();
    _getIt.registerAudioPlayer();
    _getIt.registerBattery();
    _getIt.registerDasLogTree(); // pushes without remote service
    return _getIt.allReady();
  }

  static Future<bool> pop() async {
    Fimber.d('Popping scope $_scopeName');
    return _getIt.popScopesTill(_scopeName);
  }

  static Future<bool> popAbove() async {
    Fimber.d('Popping scope above $_scopeName');
    return _getIt.popScopesTill(_scopeName, inclusive: false);
  }
}

extension BaseScopeExtension on GetIt {
  void registerFlavor(Flavor flavor) {
    Fimber.d('Register flavor');
    registerSingleton<Flavor>(flavor);
  }

  void registerBrightnessManager() {
    Fimber.d('Register ScreenBrightness');
    registerSingleton<ScreenBrightness>(ScreenBrightness());

    Fimber.d('Register BrightnessManager');
    registerSingleton<BrightnessManager>(BrightnessManagerImpl(DI.get<ScreenBrightness>()));
  }

  void registerBattery() {
    Fimber.d('Register Battery');
    registerSingleton<Battery>(Battery());
  }

  void registerAudioPlayer() {
    registerLazySingleton<AudioPlayer>(() {
      Fimber.d('Register AudioPlayer');
      return AudioPlayer();
    });
  }

  void registerDasLogTree() {
    Future<LogTree> factoryFunc() async {
      Fimber.d('Register DAS log tree');
      final flavor = DI.get<Flavor>();
      final deviceId = await DeviceIdInfo.getDeviceId();
      final AuthProvider? authProvider = DI.getOrNull<AuthProvider>();
      Client? httpClient;
      if (authProvider != null) httpClient = HttpXComponent.createHttpClient(authProvider: authProvider);
      return LoggerComponent.createDasLogTree(httpClient: httpClient, baseUrl: flavor.backendUrl, deviceId: deviceId);
    }

    registerSingletonAsync<LogTree>(factoryFunc);
  }
}
