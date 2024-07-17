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

  static Future<void> init(Flavor flavor) {
    Fimber.i('Initialize integration test dependency injection');
    GetIt.I.registerFlavor(flavor);
    GetIt.I.registerTokenSpecProvider();
    GetIt.I.registerOidcClient();
    _registerIntegrationTestAuthenticator();
    _registerMqttClientConnector();
    GetIt.I.registerServices();
    return GetIt.I.allReady();
  }

  static void _registerIntegrationTestAuthenticator() {
    GetIt.I.registerSingletonAsync<Authenticator>(() async => IntegrationtestAuthenticator());
  }

  static void _registerMqttClientConnector() {
    GetIt.I.registerSingletonAsync<MqttClientConnector>(() async => MqttClientUserConnector());
  }
}
