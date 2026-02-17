import 'package:auth/component.dart';

class IntegrationTestAuthenticator implements Authenticator {
  bool _isAuthenticated = true;

  set isAuthenticated(bool value) {
    _isAuthenticated = value;
  }

  @override
  Future<void> endSession() async {}

  @override
  Future<bool> get isAuthenticated async => _isAuthenticated;

  @override
  Future<OidcToken> login({String? tokenId}) async {
    return _token();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<OidcToken> token({String? tokenId}) async {
    return _token();
  }

  @override
  Future<User> user({String? tokenId}) async {
    return User(name: 'tester@testeee.com', roles: []);
  }

  OidcToken _token() => OidcToken(tokenType: '', accessToken: '', idToken: '');
}
