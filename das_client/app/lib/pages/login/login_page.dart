import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:app/flavor.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:auth/component.dart';
import 'package:auto_route/auto_route.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  static const routeName = 'login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  bool isTmsChecked = false;

  @override
  void initState() {
    DI.resetToUnauthenticatedScope(useTms: isTmsChecked);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: isLoading ? _loading() : _body(),
      ),
    );
  }

  Widget _loading() {
    return Container(
      alignment: AlignmentDirectional.center,
      child: const CircularProgressIndicator(),
    );
  }

  Widget _body() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        const Spacer(),
        _message(context),
        _loginButton(context),
        _tmsCheckbox(context),
        const Spacer(),
        _flavor(context),
      ],
    );
  }

  Widget _message(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.center,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 32),
          Text(
            context.l10n.p_login_login_button_description,
          ),
        ],
      ),
    );
  }

  Widget _flavor(BuildContext context) {
    final flavor = DI.get<Flavor>();
    return Container(
      alignment: AlignmentDirectional.center,
      padding: const EdgeInsets.all(16.0),
      child: Text(
        'Flavor: ${flavor.displayName}',
      ),
    );
  }

  Widget _tmsCheckbox(BuildContext context) {
    final flavor = DI.get<Flavor>();

    if (flavor.isTmsEnabledForFlavor) {
      return Padding(
        padding: const EdgeInsets.all(sbbDefaultSpacing),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SBBCheckbox(
              value: isTmsChecked,
              onChanged: (value) {
                setState(() {
                  isTmsChecked = value ?? false;
                  DI.resetToUnauthenticatedScope(useTms: isTmsChecked);
                });
              },
            ),
            Text(context.l10n.p_login_connect_to_tms),
          ],
        ),
      );
    } else {
      return Container();
    }
  }

  Widget _loginButton(BuildContext context) {
    return OutlinedButton(
      onPressed: _onLoginPressed,
      child: Text(context.l10n.p_login_login_button_text),
    );
  }

  void _onLoginPressed() async {
    final authenticator = DI.get<Authenticator>();

    setState(() {
      isLoading = true;
    });

    final context = this.context;
    try {
      await authenticator.login();
      await DI.get<ScopeHandler>().push<AuthenticatedScope>();
      if (context.mounted) {
        context.router.replace(const JourneySelectionRoute());
      }
    } catch (e) {
      Fimber.d('Login failed', ex: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.p_login_login_failed),
          ),
        );
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}
