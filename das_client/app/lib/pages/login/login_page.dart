import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/di/scopes/journey_scope.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/login/login_model.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:app/pages/login/widgets/draggable_bottom_sheet.dart';
import 'package:app/widgets/assets.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

final _log = Logger('LoginPage');

@RoutePage()
class LoginPage extends StatefulWidget implements AutoRouteWrapper {
  static const routeName = 'login';

  const LoginPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return Provider<LoginViewModel>(
      create: (_) => LoginViewModel(authenticator: DI.get<Authenticator>()),
      dispose: (_, vm) => vm.dispose(),
      child: this,
    );
  }

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late StreamSubscription<LoginModel> _subscription;

  @override
  void initState() {
    final viewModel = context.read<LoginViewModel>();
    _subscription = viewModel.model.listen((model) async {
      if (model is LoggedIn) {
        await DI.get<ScopeHandler>().push<AuthenticatedScope>();
        await DI.get<ScopeHandler>().push<JourneyScope>();
        if (mounted) {
          context.router.replace(const JourneySelectionRoute());
        }
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: .bottomCenter,
        children: [
          _background(),
          LoginDraggableBottomSheet(),
        ],
      ),
    );
  }

  Widget _background() => SvgPicture.asset(
    AppAssets.loginPageBackground,
    fit: .fill,
    width: double.infinity,
    height: double.infinity,
  );
}
