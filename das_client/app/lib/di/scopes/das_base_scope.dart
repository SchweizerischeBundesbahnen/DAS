part of 'di_scope.dart';

// Named 'DASBaseScope' to avoid confusion with GetIt's 'baseScope'.
class DASBaseScope extends DIScope {
  static const String scopeName = 'DASBaseScope';

  @override
  String get _scopeName => scopeName;

  @override
  Future<void> push() async {
    Fimber.d('Pushing scope $_scopeName');
    _getIt.pushNewScope(scopeName: _scopeName);
    _getIt.registerBrightnessManager();
    _getIt.registerAudioPlayer();
    _getIt.registerBattery();
    _getIt.registerDasLogTree(); // pushes without remote service
    return _getIt.allReady();
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
