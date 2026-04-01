import 'package:auth/component.dart';

class E2EAuthenticator implements Authenticator {
  static const accessToken = 'ACCESS_TOKEN';

  @override
  Future<void> endSession() async {}

  @override
  Future<bool> get isAuthenticated async => true;

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
    final roles = AuthenticationComponent.resolveRoles(const String.fromEnvironment(accessToken));

    return User(
      userId: 'e2e@sbb.com',
      roles: roles.map((it) => Role.fromName(it)).nonNulls.toList(),
      displayName: 'E2E Tester',
    );
  }

  OidcToken _token() => OidcToken(
    tokenType: 'Bearer',
    accessToken: const String.fromEnvironment(accessToken),
    idToken: const String.fromEnvironment(accessToken),
  );
}
