import 'package:app/auth/src/user.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

abstract class Authenticator {
  const Authenticator._();

  Future<bool> get isAuthenticated;

  Future<OidcToken> login({String? tokenId});

  Future<OidcToken> token({String? tokenId});

  Future<User> user({String? tokenId});

  Future<void> logout();

  Future<void> endSession();
}
