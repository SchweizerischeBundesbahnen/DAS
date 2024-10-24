import 'package:auto_route/auto_route.dart';
import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/di.dart';
import 'package:das_client/flavor.dart';
import 'package:das_client/nav/app_router.dart';
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
        const Spacer(),
        _flavor(context),
      ],
    );
  }

  Widget _message(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.center,
      padding: const EdgeInsets.all(16),
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 32),
          Text(
            'Login with your account',
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

  Widget _loginButton(BuildContext context) {
    return OutlinedButton(
      onPressed: _onLoginPressed,
      child: const Text('Login'),
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
        context.router.replace(const TrainSelectionRoute());
      }
    } catch (e) {
      Fimber.d('Login failed', ex: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login failed"),
        ));
      }
    }

    setState(() {
      isLoading = false;
    });
  }
}
