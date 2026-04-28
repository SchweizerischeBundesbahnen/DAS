import 'package:app/di/di.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/view_model/app_expiration_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:logging/logging.dart';

final _log = Logger('AppExpirationGuard');

class AppExpirationGuard extends AutoRouteGuard {
  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) async {
    final appExpirationVM = DI.get<AppExpirationViewModel>();
    try {
      router.push(const LoadingRoute());

      await _checkAppIsExpiredAndResolveOnTimeout(appExpirationVM, router, resolver);

      if (resolver.isResolved) return;

      // remove loading route
      router.removeLast();

      if (!appExpirationVM.mustShowDialog) {
        _log.fine('AppExpiraton dialog must not be shown. Navigating to ${resolver.route}');
        resolver.next(true);
        return;
      }

      _log.fine('AppExpiration dialog must be shown. Navigating to selection...');
      router.push(
        JourneySelectionRoute(
          onAppExpiredDialogDismissed: () {
            _log.fine('Dialog dismissed. Navigating to ${resolver.route}');
            resolver.next(true);
          },
        ),
      );
    } catch (e) {
      _log.severe('Navigation failed: $e');
      resolver.next(false);
    }
  }

  Future<void> _checkAppIsExpiredAndResolveOnTimeout(
    AppExpirationViewModel appExpirationVM,
    StackRouter router,
    NavigationResolver resolver,
  ) async {
    await appExpirationVM.checkIsAppExpired().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _log.warning('AppExpiration check timed out after 5 seconds. Resolving with next(true).');
        router.removeLast();
        resolver.next(true);
      },
    );
  }
}
