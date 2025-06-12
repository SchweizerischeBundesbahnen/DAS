// implement the mock for authenticated_scope.dart

import 'package:app/di/di.dart';
import 'package:app/di/scopes/authenticated_scope.dart';
import 'package:logging/logging.dart';

final _log = Logger('MockAuthenticatedScope');

class MockAuthenticatedScope extends AuthenticatedScope {
  @override
  String get scopeName => 'MockAuthenticatedScope';

  @override
  Future<void> push() async {
    _log.fine('Pushing mock scope $scopeName');
    getIt.pushNewScope(scopeName: scopeName);

    getIt.registerAuthProvider();
    getIt.registerSferaAuthProvider();
    getIt.registerMqttAuthProvider();
    getIt.registerMqttService();
    getIt.registerHttpClient();
    getIt.registerSferaAuthService();
    getIt.registerSferaLocalRepo();
    getIt.registerSferaRemoteRepo();
    getIt.registerJourneyNavigationViewModel();

    return getIt.allReady();
  }
}
