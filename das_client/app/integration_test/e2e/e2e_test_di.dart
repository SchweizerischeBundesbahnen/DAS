import 'package:app/di/di.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'e2e_test_authenticated_scope.dart';
import 'e2e_test_das_base_scope.dart';
import 'e2e_test_journey_scope.dart';
import 'e2e_test_sfera_mock_scope.dart';
import 'e2e_test_tms_scope.dart';

final _log = Logger('E2ETestDI');

class const E2ETestDI._() {
  static Future<void> init() async {
    _log.fine('Initialize e2e test dependency injection');
    await GetIt.I.reset();

    GetIt.I.registerFlavor(Flavor.dev());
    _registerE2ETestScopes();
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

  static void _registerE2ETestScopes() {
    GetIt.I.registerSingleton<DASBaseScope>(E2ETestDASBaseScope());
    GetIt.I.registerSingleton<SferaMockScope>(E2ETestSferaMockScope());
    GetIt.I.registerSingleton<TmsScope>(E2ETestTmsScope());
    GetIt.I.registerSingleton<AuthenticatedScope>(E2ETestAuthenticatedScope());
    GetIt.I.registerSingleton<JourneyScope>(E2ETestJourneyScope());
  }
}
