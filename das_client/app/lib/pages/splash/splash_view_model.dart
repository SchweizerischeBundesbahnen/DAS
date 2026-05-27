import 'package:auth/component.dart';

class SplashViewModel {
  SplashViewModel({required this._authenticator});

  final Authenticator _authenticator;

  Future<bool> get isAuthenticated async {
    return await _authenticator.isAuthenticated;
  }

  void dispose() {}
}
