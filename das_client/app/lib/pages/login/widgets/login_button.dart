import 'package:app/i18n/i18n.dart';
import 'package:app/pages/login/login_model.dart';
import 'package:app/pages/login/login_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class LoginButton extends StatelessWidget {
  const LoginButton({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<LoginViewModel>();

    return StreamBuilder(
      stream: vm.model,
      initialData: vm.modelValue,
      builder: (context, snap) {
        final model = snap.requireData;

        return switch (model) {
          LoggedOut() || LoggedIn() => _loginButton(context, onPressed: () => vm.login()),
          Loading() => _loginButton(context, onPressed: null),
          Error() => SBBIconButtonLarge(
            icon: SBBIcons.arrow_circle_reset_medium,
            onPressed: () => context.read<LoginViewModel>().login(),
          ),
        };
      },
    );
  }

  // TODO: change to SBBSecondaryButton with custom label once v5.0.0 is released
  // TODO: https://github.com/SchweizerischeBundesbahnen/design_system_flutter/pull/425
  Widget _loginButton(BuildContext context, {required VoidCallback? onPressed}) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.large),
        child: Text(context.l10n.p_login_login_button_text),
      ),
    );
  }
}
