import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:fimber/fimber.dart';
import 'package:get_it/get_it.dart';

import 'mocks/mock_authenticated_scope.dart';
import 'mocks/mock_das_base_scope.dart';
import 'mocks/mock_sfera_mock_scope.dart';

class IntegrationTestDI {
  const IntegrationTestDI._();

  static Future<void> init(Flavor flavor) async {
    Fimber.d('Initialize integration test dependency injection');
    await GetIt.I.reset();

    GetIt.I.registerFlavor(flavor);
    GetIt.I.registerScopeHandler();
    _registerMockScopes();

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

  static void _registerMockScopes() {
    GetIt.I.registerSingleton<DASBaseScope>(MockDASBaseScope());
    GetIt.I.registerSingleton<SferaMockScope>(MockSferaMockScope());
    GetIt.I.registerSingleton<AuthenticatedScope>(MockAuthenticatedScope());
  }
}
