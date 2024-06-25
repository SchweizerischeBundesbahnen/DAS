import 'package:auto_route/auto_route.dart';
import 'package:das_client/pages/home/home_page.dart';
import 'package:das_client/pages/login/login_page.dart';
import 'package:das_client/pages/login/splash_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends _$AppRouter {
  @override
  List<AutoRoute> get routes => [
        _splash,
        _login,
        _home,
      ];
}

// Routes

final _splash = AutoRoute(
  path: '/splash',
  page: SplashRoute.page,
  initial: true,
);

final _login = AutoRoute(
  path: '/login',
  page: LoginRoute.page,
);

final _home = AutoRoute(
  path: '/home',
  page: HomeRoute.page,
);
