import 'package:auto_route/auto_route.dart';
import 'package:das_client/pages/fahrt/fahrt_page.dart';
import 'package:das_client/pages/links/links_page.dart';
import 'package:das_client/pages/profile/profile_page.dart';
import 'package:das_client/pages/login/login_page.dart';
import 'package:das_client/pages/login/splash_page.dart';
import 'package:das_client/pages/settings/settings_page.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [_splash, _login, _fahrt, _links, _settings, _profile];

  @override
  get defaultRouteType => const RouteType.custom();
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

final _fahrt = AutoRoute(
  path: '/fahrt',
  page: FahrtRoute.page,
);

final _links = AutoRoute(
  path: '/links',
  page: LinksRoute.page,
);

final _settings = AutoRoute(
  path: '/settings',
  page: SettingsRoute.page,
);

final _profile = AutoRoute(
  path: '/profile',
  page: ProfileRoute.page,
);