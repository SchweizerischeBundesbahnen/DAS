import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/auth/azure_authenticator.dart';
import 'package:das_client/auth/token_spec_provider.dart';
import 'package:das_client/flavor.dart';
import 'package:das_client/repo/sfera_repository.dart';
import 'package:das_client/service/mqtt/mqtt_client_connector.dart';
import 'package:das_client/service/mqtt/mqtt_client_oauth_connector.dart';
import 'package:das_client/service/mqtt/mqtt_client_tms_oauth_connector.dart';
import 'package:das_client/service/mqtt/mqtt_service.dart';
import 'package:das_client/service/sfera/sfera_service.dart';
import 'package:das_client/service/sfera_auth_service.dart';
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
    registerSferaAuthService(useTms: useTms);
    registerMqttClientConnector(useTms: useTms);
    registerMqttService(useTms: useTms);
    registerRepositories();
    registerSferaService();
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

  void registerMqttService({bool useTms = false}) {
    final flavor = get<Flavor>();
    registerSingletonWithDependencies<MqttService>(
        () => MqttService(
            mqttUrl: useTms ? flavor.tmsMqttUrl! : flavor.mqttUrl,
            mqttClientConnector: get(),
            prefix: flavor.mqttTopicPrefix),
        dependsOn: [MqttClientConnector]);
  }

  void registerSferaAuthService({bool useTms = false}) {
    final flavor = get<Flavor>();
    registerSingletonWithDependencies<SferaAuthService>(
        () => SferaAuthService(
            authenticator: get(), tokenExchangeUrl: useTms ? flavor.tmsTokenExchangeUrl! : flavor.tokenExchangeUrl),
        dependsOn: [Authenticator]);
  }

  /// Azure Authenticator.
  void registerAzureAuthenticator() {
    factoryFunc() {
      return AzureAuthenticator(
        oidcClient: get(),
        tokenSpecs: get(),
      );
    }

    registerSingletonWithDependencies<Authenticator>(
      factoryFunc,
      dependsOn: [OidcClient],
    );
  }

  void registerMqttClientConnector({bool useTms = false}) {
    if (useTms) {
      registerSingletonWithDependencies<MqttClientConnector>(() => MqttClientTMSOauthConnector(sferaAuthService: get()),
          dependsOn: [SferaAuthService]);
    } else {
      registerSingletonWithDependencies<MqttClientConnector>(
          () => MqttClientOauthConnector(sferaAuthService: get(), authenticator: get()),
          dependsOn: [Authenticator, SferaAuthService]);
    }
  }

  void registerRepositories() {
    registerSingletonAsync<SferaRepository>(() async => SferaRepository());
  }

  void registerSferaService() {
    registerSingletonWithDependencies<SferaService>(() => SferaService(mqttService: get(), sferaRepository: get()),
        dependsOn: [MqttService, SferaRepository]);
  }
}
