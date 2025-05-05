import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/bloc/ux_testing_cubit.dart';
import 'package:app/brightness/brightness_manager.dart';
import 'package:app/brightness/brightness_manager_impl.dart';
import 'package:app/flavor.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:auth/component.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:http_x/component.dart';
import 'package:logger/component.dart';
import 'package:mqtt/component.dart';
import 'package:sbb_oidc/sbb_oidc.dart';
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
    registerTokenSpecProvider(useTms: useTms);
    registerOidcClient(useTms: useTms);
    registerAzureAuthenticator();
    registerMqttComponent(useTms: useTms);
    registerDasLogTree();
    registerSferaComponents(useTms: useTms);
    registerBlocs();
    registerBattery();
    registerAudioPlayer();
    await allReady();
  }

  void registerBrightnessManager() {
    // First register ScreenBrightness instance
    registerLazySingleton<ScreenBrightness>(() => ScreenBrightness());

    // Then register BrightnessManager implementation using the ScreenBrightness instance
    registerLazySingleton<BrightnessManager>(() => BrightnessManagerImpl(DI.get<ScreenBrightness>()));
  }

  void registerFlavor(Flavor flavor) {
    registerSingleton<Flavor>(flavor);
  }

  void registerTokenSpecProvider({bool useTms = false}) {
    factoryFunc() {
      final flavor = DI.get<Flavor>();
      return useTms ? flavor.tmsAuthenticatorConfig!.tokenSpecs : flavor.authenticatorConfig.tokenSpecs;
    }

    registerSingleton<TokenSpecProvider>(factoryFunc());
  }

  void registerAuthProvider() {
    factoryFunc() {
      return _AuthProvider(authenticator: DI.get());
    }

    registerFactory<AuthProvider>(factoryFunc);
  }

  // TODO: Move to auth component and handle similar to AuthProvider?
  void registerOidcClient({bool useTms = false}) {
    factoryFunc() {
      final flavor = DI.get<Flavor>();
      final authenticatorConfig = useTms ? flavor.tmsAuthenticatorConfig! : flavor.authenticatorConfig;
      return SBBOpenIDConnect.createClient(
        discoveryUrl: authenticatorConfig.discoveryUrl,
        clientId: authenticatorConfig.clientId,
        redirectUrl: authenticatorConfig.redirectUrl,
        postLogoutRedirectUrl: authenticatorConfig.postLogoutRedirectUrl,
      );
    }

    registerSingletonAsync<OidcClient>(factoryFunc);
  }

  void registerMqttComponent({bool useTms = false}) {
    final flavor = DI.get<Flavor>();

    registerLazySingleton<MqttClientConnector>(() =>
        MqttComponent.createMqttClientConnector(sferaAuthService: DI.get(), authenticator: DI.get(), useTms: useTms));

    registerLazySingleton<MqttService>(() => MqttComponent.createMqttService(
        mqttUrl: useTms ? flavor.tmsMqttUrl! : flavor.mqttUrl,
        mqttClientConnector: DI.get(),
        prefix: flavor.mqttTopicPrefix));
  }

  void registerDasLogTree() {
    factoryFunc() {
      final flavor = DI.get<Flavor>();

      final httpClient = createHttpClient(
        authProvider: _AuthProvider(authenticator: DI.get()),
      );

      return LoggerComponent.createDasLogTree(httpClient: httpClient, baseUrl: flavor.backendUrl);
    }

    registerSingletonWithDependencies<LogTree>(
      factoryFunc,
      dependsOn: [Authenticator],
    );
  }

  void registerAzureAuthenticator() {
    factoryFunc() {
      return AuthenticationComponent.createAzureAuthenticator(
        oidcClient: DI.get(),
        tokenSpecs: DI.get(),
      );
    }

    registerSingletonWithDependencies<Authenticator>(
      factoryFunc,
      dependsOn: [OidcClient],
    );
  }

  void registerSferaComponents({bool useTms = false}) {
    final flavor = DI.get<Flavor>();

    registerLazySingleton<SferaDatabaseRepository>(() => SferaComponent.createDatabaseRepository());
    registerLazySingleton<SferaAuthService>(() => SferaComponent.createSferaAuthService(
        authenticator: DI.get(), tokenExchangeUrl: useTms ? flavor.tmsTokenExchangeUrl! : flavor.tokenExchangeUrl));

    registerLazySingleton<SferaService>(
      () => SferaComponent.createSferaService(
          mqttService: DI.get(), sferaDatabaseRepository: DI.get(), authenticator: DI.get()),
      dispose: (service) => service.dispose(),
    );

    registerLazySingleton<SferaLocalService>(
        () => SferaComponent.createSferaLocalService(sferaDatabaseRepository: DI.get()));
  }

  void registerBlocs() {
    registerLazySingleton<TrainJourneyCubit>(() => TrainJourneyCubit(sferaService: DI.get()));
    registerLazySingleton<UxTestingCubit>(() => UxTestingCubit(sferaService: DI.get())..initialize());
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
