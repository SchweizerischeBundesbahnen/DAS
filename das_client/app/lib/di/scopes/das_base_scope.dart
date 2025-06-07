// Named 'DASBaseScope' to avoid confusion with GetIt's 'baseScope'.
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

class DASBaseScope extends DIScope {
  @override
  String get scopeName => 'DASBaseScope';

  @override
  Future<void> push() async {
    Fimber.d('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    getIt.registerBrightnessManager();
    getIt.registerAudioPlayer();
    getIt.registerBattery();
    getIt.registerDasLogTree(); // pushes without remote service
    await getIt.allReady();
  }
}

extension BaseScopeExtension on GetIt {
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
