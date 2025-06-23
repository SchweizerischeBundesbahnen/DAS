import 'package:app/di/di.dart';
import 'package:app/nav/app_router.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class LogoutButton extends StatelessWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(SBBIcons.exit_small),
    onPressed: () {
      DI.get<Authenticator>().logout();
      context.router.replace(const LoginRoute());
    },
  );
}
