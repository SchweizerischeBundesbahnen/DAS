import 'package:app/di.dart';
import 'package:app/pages/splash/splash_navigator.dart';
import 'package:app/pages/splash/splash_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

@RoutePage()
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  SplashNavigator? _navigator;

  @override
  Widget build(BuildContext context) {
    return Provider(
      create: (context) => SplashViewModel(authenticator: DI.get()),
      dispose: (_, vm) => vm.dispose(),
      builder: (context, _) => _scaffold(context),
    );
  }

  Widget _scaffold(BuildContext context) {
    _navigator ??= SplashNavigator(viewModel: context.read(), router: context.router);
    return Scaffold(body: _body());
  }

  Widget _body() {
    return Container(
      alignment: AlignmentDirectional.center,
      color: Colors.blue,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.black,
          )
        ],
      ),
    );
  }
}
