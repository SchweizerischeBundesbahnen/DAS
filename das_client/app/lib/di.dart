import 'package:app/brightness/brightness_manager.dart';
import 'package:app/brightness/brightness_manager_impl.dart';
import 'package:app/flavor.dart';
import 'package:app/util/device_id_info.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auth/component.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/component.dart';
import 'package:mqtt/component.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:sfera/component.dart';
import 'package:warnapp/component.dart';

class DI {
  const DI._();

  static Future<void> init(Flavor flavor) {
    Fimber.i('Initialize dependency injection');
    return GetIt.I.init(flavor);
  }

  static Future<void> reinitialize({required bool useTms}) async {
    Fimber.i('Reinitialize dependency injection with useTms=$useTms');
    final flavor = DI.get<Flavor>();
    await GetIt.I.reset();
    GetIt.I.init(flavor, useTms: useTms);

    return GetIt.I.allReady();
  }

  static T get<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
  }) {
    return GetIt.I.get(
      instanceName: instanceName,
      param1: param1,
      param2: param2,
    );
  }
}

// Internal

extension GetItX on GetIt {
  Future<void> init(Flavor flavor, {bool useTms = false}) async {
    registerFlavor(flavor);
    registerBrightnessManager();
    registerAzureAuthenticator(useTms: useTms);
    registerAuthProvider();
    registerSferaAuthProvider();
    registerMqttAuthProvider();
    registerMqttClientConnector(useTms: useTms);
    registerMqttService(useTms: useTms);
    registerDasLogTree();
    registerSferaAuthService(useTms: useTms);
    registerSferaLocalRepo();
    registerSferaRemoteRepo();
    registerBattery();
    registerAudioPlayer();
    registerWarnapp();
    await allReady();
  }

  void registerFlavor(Flavor flavor) {
    Fimber.d('Register flavor');
    registerSingleton<Flavor>(flavor);
  }

  void registerAuthProvider() {
    factoryFunc() {
      Fimber.d('Register auth provider');
      return _AuthProvider(authenticator: DI.get());
    }

    registerFactory<AuthProvider>(factoryFunc);
  }

  void registerSferaAuthProvider() {
    factoryFunc() {
      Fimber.d('Register sfera auth provider');
      return _SferaAuthProvider(authenticator: DI.get());
    }

    registerFactory<SferaAuthProvider>(factoryFunc);
  }

  void registerMqttAuthProvider() {
    factoryFunc() {
      Fimber.d('Register mqtt auth provider');
      return _MqttAuthProvider(authenticator: DI.get(), sferaAuthService: DI.get());
    }

    registerFactory<MqttAuthProvider>(factoryFunc);
  }

  void registerMqttClientConnector({bool useTms = false}) {
    factoryFunc() {
      Fimber.d('Register mqtt client connector');
      return MqttComponent.createMqttClientConnector(authProvider: DI.get(), useTms: useTms);
    }

    registerLazySingleton<MqttClientConnector>(factoryFunc);
  }

  void registerMqttService({bool useTms = false}) {
    Future<MqttService> factoryFunc() async {
      Fimber.d('Register mqtt service');
      final flavor = DI.get<Flavor>();
      final deviceId = await DeviceIdInfo.getDeviceId();
      return MqttComponent.createMqttService(
        mqttUrl: useTms ? flavor.tmsMqttUrl! : flavor.mqttUrl,
        mqttClientConnector: DI.get(),
        prefix: flavor.mqttTopicPrefix,
        deviceId: deviceId,
      );
    }

    registerSingletonAsync(factoryFunc);
  }

  void registerDasLogTree() {
    Future<LogTree> factoryFunc() async {
      Fimber.d('Register DAS log tree');
      final flavor = DI.get<Flavor>();
      final deviceId = await DeviceIdInfo.getDeviceId();
      final httpClient = HttpXComponent.createHttpClient(authProvider: DI.get());
      return LoggerComponent.createDasLogTree(httpClient: httpClient, baseUrl: flavor.backendUrl, deviceId: deviceId);
    }

    registerSingletonAsync<LogTree>(factoryFunc);
  }

  void registerAzureAuthenticator({bool useTms = false}) {
    factoryFunc() {
      Fimber.d('Register azure authenticator');
      final flavor = DI.get<Flavor>();
      final authenticatorConfig = useTms ? flavor.tmsAuthenticatorConfig! : flavor.authenticatorConfig;
      return AuthenticationComponent.createAzureAuthenticator(config: authenticatorConfig);
    }

    registerSingleton<Authenticator>(factoryFunc());
  }

  void registerSferaAuthService({bool useTms = false}) {
    factoryFunc() {
      Fimber.d('Register sfera auth service');
      final flavor = DI.get<Flavor>();
      final httpClient = HttpXComponent.createHttpClient(authProvider: DI.get());
      return SferaComponent.createSferaAuthService(
        httpClient: httpClient,
        tokenExchangeUrl: useTms ? flavor.tmsTokenExchangeUrl! : flavor.tokenExchangeUrl,
      );
    }

    registerLazySingleton<SferaAuthService>(factoryFunc);
  }

  void registerSferaRemoteRepo() {
    factoryFunc() async {
      Fimber.d('Register sfera remote repo');
      final deviceId = await DeviceIdInfo.getDeviceId();
      return SferaComponent.createSferaRemoteRepo(
        mqttService: DI.get(),
        sferaAuthProvider: DI.get(),
        deviceId: deviceId,
      );
    }

    registerSingletonAsync<SferaRemoteRepo>(
      factoryFunc,
      dispose: (repo) => repo.dispose(),
      dependsOn: [MqttService],
    );
  }

  void registerSferaLocalRepo() {
    factoryFunc() {
      Fimber.d('Register sfera local repo');
      return SferaComponent.createSferaLocalRepo();
    }

    registerLazySingleton<SferaLocalRepo>(factoryFunc);
  }

  void registerBrightnessManager() {
    registerLazySingleton<ScreenBrightness>(() {
      Fimber.d('Register ScreenBrightness');
      return ScreenBrightness();
    });

    registerLazySingleton<BrightnessManager>(() {
      Fimber.d('Register BrightnessManager');
      return BrightnessManagerImpl(DI.get<ScreenBrightness>());
    });
  }

  void registerBattery() {
    registerLazySingleton<Battery>(() {
      Fimber.d('Register Battery');
      return Battery();
    });
  }

  void registerAudioPlayer() {
    registerLazySingleton<AudioPlayer>(() {
      Fimber.d('Register AudioPlayer');
      return AudioPlayer();
    });
  }

  void registerWarnapp() {
    registerSingleton(WarnappComponent.createWarnappService());
  }
}

class _AuthProvider implements AuthProvider {
  const _AuthProvider({required this.authenticator});

  final Authenticator authenticator;

  @override
  Future<String> call({String? tokenId}) async {
    final oidcToken = await authenticator.token(tokenId: tokenId);
    final accessToken = oidcToken.accessToken;
    return '${oidcToken.tokenType} $accessToken';
  }
}

class _SferaAuthProvider implements SferaAuthProvider {
  const _SferaAuthProvider({required this.authenticator});

  final Authenticator authenticator;

  @override
  Future<bool> isDriver() async {
    final user = await authenticator.user();
    return user.roles.contains(Role.driver);
  }
}

class _MqttAuthProvider implements MqttAuthProvider {
  const _MqttAuthProvider({required this.authenticator, required this.sferaAuthService});

  final SferaAuthService sferaAuthService;
  final Authenticator authenticator;

  @override
  Future<String?> tmsToken({required String company, required String train, required String role}) {
    return sferaAuthService.retrieveAuthToken(company, train, role);
  }

  @override
  Future<String> token() async {
    final token = await authenticator.token();
    return token.accessToken;
  }

  @override
  Future<String> userId() async {
    final user = await authenticator.user();
    return user.name;
  }
}
