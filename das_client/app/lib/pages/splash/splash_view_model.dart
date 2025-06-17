import 'package:auth/component.dart';

class SplashViewModel {
  SplashViewModel({required Authenticator authenticator}) : _authenticator = authenticator;

  final Authenticator _authenticator;

  Future<bool> get isAuthenticated async {
    return await _authenticator.isAuthenticated;
  }

  void dispose() {}
}
