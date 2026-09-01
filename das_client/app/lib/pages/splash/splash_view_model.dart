import 'package:auth/component.dart';

class SplashViewModel({required final Authenticator _authenticator}) {
  Future<bool> get isAuthenticated => _authenticator.isAuthenticated;

  void dispose() {}
}
