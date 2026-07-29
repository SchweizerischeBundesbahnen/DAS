import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';

import '../auth/e2e_test_authenticator.dart';

final _log = Logger('E2ETestSferaMockScope');

class E2ETestSferaMockScope extends SferaMockScope {
  @override
  String get scopeName => 'E2ETestSferaMockScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);
    final sferaFlavor = DI.get<Flavor>().withSferaMockValues();

    getIt.registerFlavor(sferaFlavor);
    _registerE2ETestAuthenticator();
    getIt.registerOAuthMqttClientConnector();
    await getIt.allReady();
  }

  void _registerE2ETestAuthenticator() {
    getIt.registerSingletonAsync<Authenticator>(() async => E2ETestAuthenticator());
  }
}
