import 'package:auto_route/auto_route.dart';
import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/di.dart';
import 'package:das_client/flavor.dart';
import 'package:das_client/i18n/i18n.dart';
import 'package:das_client/nav/app_router.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';

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
    DI.reinitialize(useTms: isTmsChecked);
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
    var flavor = DI.get<Flavor>();

    if (flavor.tmsAuthenticatorConfig != null && flavor.tmsMqttUrl != null && flavor.tmsTokenExchangeUrl != null) {
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
                  DI.reinitialize(useTms: isTmsChecked);
                });
              },
            ),
            Text(context.l10n.p_login_connect_to_tms)
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
      if (context.mounted) {
        context.router.replace(const JourneyRoute());
      }
    } catch (e) {
      Fimber.d('Login failed', ex: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(context.l10n.p_login_login_failed),
        ));
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}
