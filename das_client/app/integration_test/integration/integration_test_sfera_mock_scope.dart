import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:settings/component.dart';

import '../auth/integration_test_authenticator.dart';
import '../auth/mqtt_client_user_connector.dart';
import '../mocks/mock_settings_repository.dart';

final _log = Logger('IntegrationTestSferaMockScope');

class IntegrationTestSferaMockScope extends SferaMockScope {
  @override
  String get scopeName => 'IntegrationTestSferaMockScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    final sferaFlavor = DI.get<Flavor>().withSferaMockValues();

    getIt.registerFlavor(sferaFlavor);
    _registerIntegrationTestAuthenticator();
    _registerIntegrationTestMqttClientConnector();
    _registerMockSettingsRepository(); // registered here so can be interacted with before app is started after DI init
  }

  void _registerMockSettingsRepository() {
    getIt.registerSingletonAsync<SettingsRepository>(() => Future.value(MockSettingsRepository()));
  }

  void _registerIntegrationTestAuthenticator() {
    getIt.registerSingletonAsync<Authenticator>(() async => IntegrationTestAuthenticator());
  }

  void _registerIntegrationTestMqttClientConnector() {
    getIt.registerSingletonAsync<MqttClientConnector>(() async => MqttClientUserConnector());
  }
}
