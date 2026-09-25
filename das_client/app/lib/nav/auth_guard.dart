import 'package:app/di/di.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:get_it/get_it.dart';
import 'package:logging/logging.dart';

final _log = Logger('AuthGuard');

class AuthGuard({required final Authenticator _authenticator}) extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    try {
      if (await _authenticator.isAuthenticated) {
        final journeyActive = GetIt.I.hasScope(JourneyScope.journeyScopeName);

        if (_authenticator.reauthenticationRequiredValue && !journeyActive) {
          _log.fine('Reauthentication required. Prompting login...');
          _authenticator.login();
        }

        _log.fine('Authenticated. Navigating to ${resolver.route}');
        resolver.next(true);
        return;
      }

      _log.info('Not authenticated. Navigating to login...');
      final loginModel = DI.get<LoginViewModel>().modelValue;
      DI.resetToUnauthenticatedScope(useTms: loginModel.connectToTmsVad);
      router.push(
        LoginRoute(
          onSuccess: () {
            _log.info('Login successful. Navigating to ${resolver.route}');
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
