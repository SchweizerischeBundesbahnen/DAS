import 'package:app/di/di.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logging/logging.dart';

final _log = Logger('AuthGuard');

class AuthGuard extends AutoRouteGuard {
  AuthGuard({
    required Authenticator authenticator,
  }) : _authenticator = authenticator;

  final Authenticator _authenticator;

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      if (await _authenticator.isAuthenticated) {
        _log.fine('Authenticated. Navigating to ${resolver.route}');
        resolver.next(true);
        return;
      }

      _log.fine('Not authenticated. Navigating to login...');
      final loginModel = DI.get<LoginViewModel>().modelValue;
      DI.resetToUnauthenticatedScope(useTms: loginModel.connectToTmsVad);
      router.push(
        LoginRoute(
          onSuccess: () {
            _log.fine('Login successful. Navigating to ${resolver.route}');
            resolver.next(true);
          },
        ),
      );
    } catch (e) {
      _log.severe('Navigation failed: $e');
      resolver.next(false);
    }
  }
}
