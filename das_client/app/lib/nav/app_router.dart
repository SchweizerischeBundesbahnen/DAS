import 'package:app/nav/auth_guard.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_page.dart';
import 'package:app/pages/journey/journey_page.dart';
import 'package:app/pages/journey/selection/journey_selection_page.dart';
import 'package:app/pages/links/links_page.dart';
import 'package:app/pages/login/login_page.dart';
import 'package:app/pages/profile/profile_page.dart';
import 'package:app/pages/settings/settings_page.dart';
import 'package:app/pages/splash/splash_page.dart';
import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sfera/component.dart';

part 'app_router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class AppRouter extends RootStackRouter {
  AppRouter({required this.authGuard});

  final AuthGuard authGuard;

  @override
  List<AutoRoute> get routes => [
    _splash,
    _login,
    _journey,
    _journeySelection,
    _links,
    _settings,
    _profile,
    _breakLoadSlip,
  ];

  AutoRoute get _splash => AutoRoute(
    path: '/splash',
    page: SplashRoute.page,
    initial: true,
  );

  AutoRoute get _login => AutoRoute(
    path: '/login',
    page: LoginRoute.page,
  );

  AutoRoute get _journey => AutoRoute(
    path: '/journey',
    page: JourneyRoute.page,
    guards: [authGuard],
  );

  AutoRoute get _journeySelection => AutoRoute(
    path: '/journey-selection',
    page: JourneySelectionRoute.page,
    guards: [authGuard],
  );

  AutoRoute get _links => AutoRoute(
    path: '/links',
    page: LinksRoute.page,
    guards: [authGuard],
  );

  AutoRoute get _settings => AutoRoute(
    path: '/settings',
    page: SettingsRoute.page,
    guards: [authGuard],
  );

  AutoRoute get _profile => AutoRoute(
    path: '/profile',
    page: ProfileRoute.page,
    guards: [authGuard],
  );

  AutoRoute get _breakLoadSlip => AutoRoute(
    path: '/break-load-slip',
    page: BreakLoadSlipRoute.page,
    guards: [authGuard],
  );

  @override
  get defaultRouteType => RouteType.custom();
}
