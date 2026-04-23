import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';
import 'package:settings/component.dart';

import '../auth/e2e_authenticator.dart';
import '../auth/integrationtest_authenticator.dart';
import '../auth/mqtt_client_user_connector.dart';
import 'mock_settings_repository.dart';

final _log = Logger('MockSferaMockScope');

class MockSferaMockScope extends SferaMockScope {
  MockSferaMockScope(this.e2e);

  final bool e2e;

  @override
  String get scopeName => 'MockSferaMockScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    final sferaFlavor = DI.get<Flavor>().withSferaMockValues();

    getIt.registerFlavor(sferaFlavor);
    if (e2e) {
      _registerE2EAuthenticator();
    } else {
      _registerIntegrationTestAuthenticator();
    }
    _registerIntegrationTestMqttClientConnector();
    _registerMockSettingsRepository(); // registered here so can be interacted with before app is started after DI init
  }

  void _registerMockSettingsRepository() {
    getIt.registerSingletonAsync<SettingsRepository>(() => Future.value(MockSettingsRepository()));
  }

  void _registerE2EAuthenticator() {
    getIt.registerSingletonAsync<Authenticator>(() async => E2EAuthenticator());
  }

  void _registerIntegrationTestAuthenticator() {
    getIt.registerSingletonAsync<Authenticator>(() async => IntegrationTestAuthenticator());
  }

  void _registerIntegrationTestMqttClientConnector() {
    getIt.registerSingletonAsync<MqttClientConnector>(() async => MqttClientUserConnector());
  }
}
