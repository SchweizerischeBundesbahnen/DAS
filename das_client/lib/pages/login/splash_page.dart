import 'package:auto_route/auto_route.dart';
import 'package:das_client/auth/authentication_component.dart';
import 'package:das_client/auth/src/authenticator.dart';
import 'package:das_client/di.dart';
import 'package:das_client/nav/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  Authenticator get authenticator => DI.get();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          context.router.replace(const JourneyRoute());
        } else if (state is Unauthenticated) {
          context.router.replace(const LoginRoute());
        }

        return _loading();
      },
    );
  }

  Widget _loading() {
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
