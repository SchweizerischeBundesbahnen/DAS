import 'package:app/di/di.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'integration_test_authenticated_scope.dart';
import 'integration_test_das_base_scope.dart';
import 'integration_test_journey_scope.dart';
import 'integration_test_sfera_mock_scope.dart';
import 'integration_test_tms_scope.dart';

final _log = Logger('IntegrationTestDI');

class const IntegrationTestDI._() {
  static Future<void> init() async {
    _log.fine('Initialize integration test dependency injection');
    await GetIt.I.reset();

    GetIt.I.registerFlavor(Flavor.dev());
    _registerIntegrationTestScopes();
    GetIt.I.registerScopeHandler();

    await GetIt.I.allReady();
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

  static void _registerIntegrationTestScopes() {
    GetIt.I.registerSingleton<DASBaseScope>(IntegrationTestDASBaseScope());
    GetIt.I.registerSingleton<SferaMockScope>(IntegrationTestSferaMockScope());
    GetIt.I.registerSingleton<TmsScope>(IntegrationTestTmsScope());
    GetIt.I.registerSingleton<AuthenticatedScope>(IntegrationTestAuthenticatedScope());
    GetIt.I.registerSingleton<JourneyScope>(IntegrationTestJourneyScope());
  }
}
