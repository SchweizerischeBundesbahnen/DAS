import 'package:das_client/auth/authentication_component.dart';
import 'package:flutter/foundation.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

class IntegrationtestAuthenticator implements Authenticator {
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
    return User(name: 'tester@testeee.com', roles: []);
  }

  OidcToken _token() {
    return OidcToken(
        tokenType: '',
        accessToken: const AccessToken(''),
        idToken: JsonWebToken(
            header: const <String, dynamic>{}, payload: const <String, dynamic>{}, signature: Uint8List.fromList([])));
  }
}
