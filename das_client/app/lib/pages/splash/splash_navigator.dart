import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/splash/splash_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logging/logging.dart';

final _log = Logger('SplashNavigator');

class SplashNavigator {
  SplashNavigator({required this.viewModel, required this.router}) {
    _init();
  }

  final SplashViewModel viewModel;
  final StackRouter router;

  void _init() {
    _checkAuthenticationState();
  }

  Future<void> _checkAuthenticationState() async {
    final isAuthenticated = await viewModel.isAuthenticated;
    if (isAuthenticated) {
      await DI.get<ScopeHandler>().push<AuthenticatedScope>();
      _navigateToJourney();
    } else {
      _navigateToLogin();
    }
  }

  Future<void> _navigateToJourney() async {
    _log.fine('Navigate to home');
    try {
      router.replaceAll([JourneySelectionRoute()]);
    } catch (e, s) {
      _log.severe('Navigate to journey failed', e, s);
    }
  }

  Future<void> _navigateToLogin() async {
    _log.fine('Navigate to login');
    try {
      router.replaceAll([LoginRoute()]);
    } catch (e, s) {
      _log.severe('Navigate to login failed', e, s);
    }
  }
}
