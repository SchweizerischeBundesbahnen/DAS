import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/bloc/ux_testing_cubit.dart';
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
    registerBrightnessManager();
    registerFlavor(flavor);
    registerAzureAuthenticator(useTms: useTms);
    registerAuthProvider();
    registerSferaAuthProvider();
    registerMqttAuthProvider();
    registerMqttComponent(useTms: useTms);
    registerDasLogTree();
    registerSferaComponents(useTms: useTms);
    registerBlocs();
    registerBattery();
    registerAudioPlayer();
    await allReady();
  }

  void registerBrightnessManager() {
    registerLazySingleton<ScreenBrightness>(() => ScreenBrightness());
    registerLazySingleton<BrightnessManager>(() => BrightnessManagerImpl(DI.get<ScreenBrightness>()));
  }

  void registerFlavor(Flavor flavor) {
    registerSingleton<Flavor>(flavor);
  }

  void registerAuthProvider() {
    factoryFunc() {
      Fimber.i('registerAuthProvider');
      return _AuthProvider(authenticator: DI.get());
    }

    registerFactory<AuthProvider>(factoryFunc);
  }

  void registerSferaAuthProvider() {
    factoryFunc() {
      Fimber.i('registerSferaAuthProvider');
      return _SferaAuthProvider(authenticator: DI.get());
    }

    registerFactory<SferaAuthProvider>(factoryFunc);
  }

  void registerMqttAuthProvider() {
    factoryFunc() {
      Fimber.i('registerMqttAuthProvider');
      return _MqttAuthProvider(authenticator: DI.get(), sferaAuthService: DI.get());
    }

    registerFactory<MqttAuthProvider>(factoryFunc);
  }

  void registerMqttComponent({bool useTms = false}) {
    registerLazySingleton<MqttClientConnector>(() {
      Fimber.i('createMqttClientConnector');
      return MqttComponent.createMqttClientConnector(authProvider: DI.get(), useTms: useTms);
    });

    registerSingletonAsync(() async {
      Fimber.i('register createMqttService');
      final flavor = DI.get<Flavor>();
      final deviceId = await DeviceIdInfo.getDeviceId();
      return MqttComponent.createMqttService(
        mqttUrl: useTms ? flavor.tmsMqttUrl! : flavor.mqttUrl,
        mqttClientConnector: DI.get(),
        prefix: flavor.mqttTopicPrefix,
        deviceId: deviceId,
      );
    });
  }

  void registerDasLogTree() {
    Future<LogTree> factoryFunc() async {
      Fimber.i('registerDasLogTree');
      final flavor = DI.get<Flavor>();
      final deviceId = await DeviceIdInfo.getDeviceId();
      final httpClient = HttpXComponent.createHttpClient(authProvider: DI.get());
      return LoggerComponent.createDasLogTree(httpClient: httpClient, baseUrl: flavor.backendUrl, deviceId: deviceId);
    }

    registerSingletonAsync<LogTree>(factoryFunc);
  }

  void registerAzureAuthenticator({bool useTms = false}) {
    factoryFunc() {
      Fimber.i('registerAzureAuthenticator');
      final flavor = DI.get<Flavor>();
      final authenticatorConfig = useTms ? flavor.tmsAuthenticatorConfig! : flavor.authenticatorConfig;
      return AuthenticationComponent.createAzureAuthenticator(config: authenticatorConfig);
    }

    registerSingleton<Authenticator>(factoryFunc());
  }

  void registerSferaComponents({bool useTms = false}) {
    registerLazySingleton<SferaAuthService>(() {
      Fimber.i('SferaAuthService');
      final flavor = DI.get<Flavor>();
      final httpClient = HttpXComponent.createHttpClient(authProvider: DI.get());
      return SferaComponent.createSferaAuthService(
        httpClient: httpClient,
        tokenExchangeUrl: useTms ? flavor.tmsTokenExchangeUrl! : flavor.tokenExchangeUrl,
      );
    });

    registerSingletonAsync<SferaRemoteRepo>(
      () async {
        Fimber.i('SferaService');
        final deviceId = await DeviceIdInfo.getDeviceId();
        return SferaComponent.createSferaService(
          mqttService: DI.get(),
          sferaAuthProvider: DI.get(),
          deviceId: deviceId,
        );
      },
      dispose: (service) => service.dispose(),
      dependsOn: [MqttService],
    );

    registerLazySingleton<SferaLocalService>(() => SferaComponent.createSferaLocalService());
  }

  void registerBlocs() {
    registerSingletonWithDependencies<TrainJourneyCubit>(
      () => TrainJourneyCubit(sferaService: DI.get()),
      dependsOn: [SferaRemoteRepo],
    );
    registerSingletonWithDependencies<UxTestingCubit>(
      () => UxTestingCubit(sferaService: DI.get())..initialize(),
      dependsOn: [SferaRemoteRepo],
    );
  }

  void registerBattery() {
    registerLazySingleton<Battery>(() => Battery());
  }

  void registerAudioPlayer() {
    registerLazySingleton<AudioPlayer>(() => AudioPlayer());
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
