import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:settings/component.dart';

import '../auth/integration_test_authenticator.dart';
import '../auth/mqtt_client_user_connector.dart';
import '../mocks/mock_settings_repository.dart';

final _log = Logger('MockTmsScope');

class IntegrationTestTmsScope extends TmsScope {
  @override
  String get scopeName => 'IntegrationTestTmsScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    final tmsFlavor = DI.get<Flavor>().withTmsValues();

    getIt.registerFlavor(tmsFlavor);
    _registerIntegrationTestAuthenticator();
    _registerIntegrationTestMqttClientConnector();
    _registerMockSettingsRepository(); // registered here so can be interacted with before app is started after DI init

    return getIt.allReady();
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
