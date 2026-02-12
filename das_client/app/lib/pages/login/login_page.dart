import 'dart:async';

import 'package:app/di/di.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/login/login_model.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:app/pages/login/widgets/draggable_bottom_sheet.dart';
import 'package:app/widgets/assets.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

@RoutePage()
class LoginPage extends StatefulWidget implements AutoRouteWrapper {
  const LoginPage({super.key, this.onSuccess});

  /// Callback when login was successful.
  ///
  /// Important: If set, it is expected that the callback handles navigation.
  final void Function()? onSuccess;

  @override
  Widget wrappedRoute(BuildContext context) {
    return Provider<LoginViewModel>(
      create: (_) => DI.get<LoginViewModel>(),
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
        if (mounted) {
          if (widget.onSuccess != null) {
            // navigation is handled outside
            widget.onSuccess!();
          } else {
            context.router.replace(const JourneySelectionRoute());
          }
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
