import 'package:app/di/di.dart';
import 'package:auth/component.dart';

import '../auth/e2e_authenticator.dart';

/// Shadows [Authenticator] with [E2EAuthenticator].
///
/// Must be pushed after SferaMockScope/TmsScope and before AuthenticatedScope is pushed:
/// AuthenticatedScope's providers (_AuthProvider, _SferaAuthProvider, _MqttAuthProvider)
/// resolve [Authenticator] eagerly at registration time.
class E2EAuthenticatorOverrideScope extends DIScope {
  @override
  String get scopeName => 'E2EAuthenticatorOverrideScope';

  @override
  Future<void> push() async {
    getIt.pushNewScope(
      scopeName: scopeName,
      init: (getIt) => getIt.registerSingleton<Authenticator>(E2EAuthenticator()),
    );
  }
}
