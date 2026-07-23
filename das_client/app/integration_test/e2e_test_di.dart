import 'package:app/di/di.dart';
import 'package:app/flavor.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

import 'e2e/e2e_authenticator_override_scope.dart';
import 'e2e/e2e_warnapp_override_scope.dart';

final _log = Logger('E2ETestDI');

class E2ETestDI {
  const E2ETestDI._();

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
    GetIt.I.registerScopes();
    GetIt.I.registerSingleton<E2EWarnappOverrideScope>(E2EWarnappOverrideScope());
    GetIt.I.registerSingleton<E2EAuthenticatorOverrideScope>(E2EAuthenticatorOverrideScope());
  }
}
