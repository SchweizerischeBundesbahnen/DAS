import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';
import 'package:mqtt/component.dart';

import '../auth/integrationtest_authenticator.dart';
import '../auth/mqtt_client_user_connector.dart';

final _log = Logger('MockTmsScope');

class MockTmsScope extends TmsScope {
  @override
  String get scopeName => 'MockTmsScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    final tmsFlavor = DI.get<Flavor>().withTmsValues();

    getIt.registerFlavor(tmsFlavor);
    _registerIntegrationTestAuthenticator();
    _registerIntegrationTestMqttClientConnector();

    return getIt.allReady();
  }

  void _registerIntegrationTestAuthenticator() {
    getIt.registerSingletonAsync<Authenticator>(() async => IntegrationTestAuthenticator());
  }

  void _registerIntegrationTestMqttClientConnector() {
    getIt.registerSingletonAsync<MqttClientConnector>(() async => MqttClientUserConnector());
  }
}
