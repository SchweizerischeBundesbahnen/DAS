import 'package:app/di/scope/authenticated_scope.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/splash/splash_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fimber/fimber.dart';

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
      AuthenticatedScope.push();
      _navigateToJourney();
    } else {
      _navigateToLogin();
    }
  }

  Future<void> _navigateToJourney() async {
    Fimber.d('Navigate to home');
    try {
      router.replaceAll([JourneyRoute()]);
    } catch (e, s) {
      Fimber.e('Navigate to journey failed', ex: e, stacktrace: s);
    }
  }

  Future<void> _navigateToLogin() async {
    Fimber.d('Navigate to login');
    try {
      router.replaceAll([LoginRoute()]);
    } catch (e, s) {
      Fimber.e('Navigate to login failed', ex: e, stacktrace: s);
    }
  }
}
