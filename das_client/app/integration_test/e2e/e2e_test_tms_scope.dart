import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';

import '../auth/e2e_test_authenticator.dart';

final _log = Logger('E2ETestTmsScope');

class E2ETestTmsScope extends TmsScope {
  @override
  String get scopeName => 'E2ETestTmsScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    final tmsFlavor = DI.get<Flavor>().withTmsValues();

    getIt.registerFlavor(tmsFlavor);
    _registerE2ETestAuthenticator();
    getIt.registerOpenIdMqttClientConnector();
    await getIt.allReady();
  }

  void _registerE2ETestAuthenticator() {
    getIt.registerSingletonAsync<Authenticator>(() async => E2ETestAuthenticator());
  }
}
