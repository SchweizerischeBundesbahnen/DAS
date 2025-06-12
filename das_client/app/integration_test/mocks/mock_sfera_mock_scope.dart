import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';

import '../auth/integrationtest_authenticator.dart';
import '../auth/mqtt_client_user_connector.dart';

final _log = Logger('MockSferaMockScope');

class MockSferaMockScope extends SferaMockScope {
  @override
  String get scopeName => 'SferaMockScopeMock';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    final sferaFlavor = DI.get<Flavor>().withSferaMockValues();

    getIt.registerFlavor(sferaFlavor);
    _registerIntegrationTestAuthenticator();

    _registerIntegrationTestMqttClientConnector();
  }

  void _registerIntegrationTestAuthenticator() {
    getIt.registerSingletonAsync<Authenticator>(() async => IntegrationTestAuthenticator());
  }

  void _registerIntegrationTestMqttClientConnector() {
    getIt.registerSingletonAsync<MqttClientConnector>(() async => MqttClientUserConnector());
  }
}
