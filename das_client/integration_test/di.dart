import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/di.dart';
import 'package:das_client/flavor.dart';
import 'package:das_client/service/mqtt/mqtt_client_connector.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';

import 'auth/integrationtest_authenticator.dart';
import 'auth/mqtt_client_user_connector.dart';

class IntegrationTestDI {
  const IntegrationTestDI._();
  static bool _initialized = false;

  static Future<void> init(Flavor flavor) {
    if (_initialized) {
      return GetIt.I.allReady();
    } else {
      Fimber.i('Initialize integration test dependency injection');
      GetIt.I.registerFlavor(flavor);
      GetIt.I.registerTokenSpecProvider();
      GetIt.I.registerOidcClient();
      _registerIntegrationTestAuthenticator();
      GetIt.I.registerBackendService();
      _registerMqttClientConnector();
      GetIt.I.registerMqttService();
      GetIt.I.registerRepositories();
      GetIt.I.registerServices();
      _initialized = true;
    }
    return GetIt.I.allReady();
  }

  static void _registerIntegrationTestAuthenticator() {
    GetIt.I.registerSingletonAsync<Authenticator>(() async => IntegrationtestAuthenticator());
  }

  static void _registerMqttClientConnector() {
    GetIt.I.registerSingletonAsync<MqttClientConnector>(() async => MqttClientUserConnector());
  }
}
