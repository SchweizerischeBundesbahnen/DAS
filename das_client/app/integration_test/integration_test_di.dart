import 'package:app/di/di.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'mocks/mock_authenticated_scope.dart';
import 'mocks/mock_das_base_scope.dart';
import 'mocks/mock_journey_scope.dart';
import 'mocks/mock_sfera_mock_scope.dart';
import 'mocks/mock_tms_scope.dart';

final _log = Logger('IntegrationTestDI');

class IntegrationTestDI {
  const IntegrationTestDI._();

  static Future<void> init(Flavor flavor, {bool e2e = false}) async {
    _log.fine('Initialize integration test dependency injection');
    await GetIt.I.reset();

    GetIt.I.registerFlavor(flavor);
    _registerMockScopes(e2e);
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

  static void _registerMockScopes(bool e2e) {
    GetIt.I.registerSingleton<DASBaseScope>(MockDASBaseScope(e2e));
    GetIt.I.registerSingleton<SferaMockScope>(MockSferaMockScope(e2e));
    GetIt.I.registerSingleton<TmsScope>(MockTmsScope(e2e));
    GetIt.I.registerSingleton<AuthenticatedScope>(MockAuthenticatedScope(e2e));
    GetIt.I.registerSingleton<JourneyScope>(MockJourneyScope());
  }
}
