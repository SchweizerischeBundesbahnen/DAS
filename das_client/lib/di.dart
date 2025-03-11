import 'package:battery_plus/battery_plus.dart';
import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/bloc/ux_testing_cubit.dart';
import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/flavor.dart';
import 'package:das_client/mqtt/mqtt_component.dart';
import 'package:das_client/service/backend_service.dart';
import 'package:das_client/sfera/sfera_component.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

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
    registerTokenSpecProvider(useTms: useTms);
    registerOidcClient(useTms: useTms);
    registerAzureAuthenticator();
    registerMqttComponent(useTms: useTms);
    registerSferaComponents(useTms: useTms);
    registerBackendService();
    registerBlocs();
    registerBattery();
    await allReady();
  }

  void registerFlavor(Flavor flavor) {
    registerSingleton<Flavor>(flavor);
  }

  void registerTokenSpecProvider({bool useTms = false}) {
    factoryFunc() {
      final flavor = get<Flavor>();
      return useTms ? flavor.tmsAuthenticatorConfig!.tokenSpecs : flavor.authenticatorConfig.tokenSpecs;
    }

    registerSingleton<TokenSpecProvider>(factoryFunc());
  }

  void registerOidcClient({bool useTms = false}) {
    factoryFunc() {
      final flavor = get<Flavor>();
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
    final flavor = get<Flavor>();

    registerLazySingleton<MqttClientConnector>(
        () => MqttComponent.createMqttClientConnector(sfereAuthService: get(), authenticator: get(), useTms: useTms));

    registerLazySingleton<MqttService>(() => MqttComponent.createMqttService(
        mqttUrl: useTms ? flavor.tmsMqttUrl! : flavor.mqttUrl,
        mqttClientConnector: get(),
        prefix: flavor.mqttTopicPrefix));
  }

  /// Azure Authenticator.
  void registerAzureAuthenticator() {
    factoryFunc() {
      return AuthenticationComponent.createAzureAuthenticator(
        oidcClient: get(),
        tokenSpecs: get(),
      );
    }

    registerSingletonWithDependencies<Authenticator>(
      factoryFunc,
      dependsOn: [OidcClient],
    );
  }

  void registerSferaComponents({bool useTms = false}) {
    final flavor = get<Flavor>();

    registerLazySingleton<SferaRepository>(() => SferaComponent.createRepository());
    registerLazySingleton<SferaAuthService>(() => SferaComponent.createSferaAuthService(
        authenticator: get(), tokenExchangeUrl: useTms ? flavor.tmsTokenExchangeUrl! : flavor.tokenExchangeUrl));

    registerLazySingleton<SferaService>(
        () => SferaComponent.createSferaService(mqttService: get(), sferaRepository: get(), authenticator: get()));
  }

  void registerBackendService() {
    final flavor = get<Flavor>();
    registerSingletonWithDependencies<BackendService>(
        () => BackendService(authenticator: DI.get(), baseUrl: flavor.backendUrl),
        dependsOn: [Authenticator]);
  }

  void registerBlocs() {
    registerLazySingleton<TrainJourneyCubit>(() => TrainJourneyCubit(sferaService: get()));
    registerLazySingleton<UxTestingCubit>(() => UxTestingCubit(sferaService: get())..initialize());
  }

  void registerBattery() {
    registerLazySingleton<Battery>(() => Battery());
  }
}
