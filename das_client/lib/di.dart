import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/auth/azure_authenticator.dart';
import 'package:das_client/auth/token_spec_provider.dart';
import 'package:das_client/flavor.dart';
import 'package:das_client/service/backend_service.dart';
import 'package:das_client/service/mqtt/mqtt_client_connector.dart';
import 'package:das_client/service/mqtt/mqtt_client_oauth_connector.dart';
import 'package:das_client/service/mqtt/mqtt_service.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

class DI {
  const DI._();

  static Future<void> init(Flavor flavor) {
    Fimber.i('Initialize dependency injection');
    return GetIt.I.init(flavor);
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
  Future<void> init(Flavor flavor) async {
    registerFlavor(flavor);
    registerTokenSpecProvider();
    registerOidcClient();
    registerAzureAuthenticator();
    registerBackendService();
    registerMqttClientConnector();
    registerMqttService();
    await allReady();
  }

  void registerFlavor(Flavor flavor) {
    registerSingleton<Flavor>(flavor);
  }

  void registerTokenSpecProvider() {
    factoryFunc() {
      final flavor = get<Flavor>();
      return flavor.authenticatorConfig.tokenSpecs;
    }

    registerSingleton<TokenSpecProvider>(factoryFunc());
  }

  void registerOidcClient() {
    factoryFunc() {
      final flavor = get<Flavor>();
      final authenticatorConfig = flavor.authenticatorConfig;
      return SBBOpenIDConnect.createClient(
        discoveryUrl: authenticatorConfig.discoveryUrl,
        clientId: authenticatorConfig.clientId,
        redirectUrl: authenticatorConfig.redirectUrl,
        postLogoutRedirectUrl: authenticatorConfig.postLogoutRedirectUrl,
      );
    }

    registerSingletonAsync<OidcClient>(factoryFunc);
  }

  void registerMqttService() {
    final flavor = get<Flavor>();
    registerSingletonWithDependencies<MqttService>(
            () => MqttService(mqttUrl: flavor.mqttUrl, mqttClientConnector: get()),
        dependsOn: [MqttClientConnector]);
  }

  void registerBackendService() {
    final flavor = get<Flavor>();
    registerSingletonWithDependencies<BackendService>(
            () => BackendService(authenticator: get(), backendUrl: flavor.backendUrl),
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

  void registerMqttClientConnector() {
    registerSingletonWithDependencies<MqttClientConnector>(
        () => MqttClientOauthConnector(backendService: get(), authenticator: get()),
        dependsOn: [Authenticator, BackendService]);
  }
}
