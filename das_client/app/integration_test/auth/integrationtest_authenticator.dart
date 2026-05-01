import 'package:auth/component.dart';
import 'package:rxdart/rxdart.dart';

class IntegrationTestAuthenticator implements Authenticator {
  bool _isAuthenticated = true;
  final reauthenticationRequiredSubject = BehaviorSubject.seeded(false);

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
    return User(userId: 'tester@testeee.com', roles: [], displayName: 'Integration Tester');
  }

  OidcToken _token() => OidcToken(tokenType: '', accessToken: '', idToken: '');

  @override
  Stream<bool> get reauthenticationRequired => reauthenticationRequiredSubject.distinct();
}
