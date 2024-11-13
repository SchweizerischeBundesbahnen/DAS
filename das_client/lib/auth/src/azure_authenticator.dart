import 'dart:async';

import 'package:collection/collection.dart';
import 'package:das_client/auth/src/authenticator.dart';
import 'package:das_client/auth/src/role.dart';
import 'package:das_client/auth/src/token_spec.dart';
import 'package:das_client/auth/src/token_spec_provider.dart';
import 'package:das_client/auth/src/user.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

class AzureAuthenticator implements Authenticator {
  AzureAuthenticator({
    required this.oidcClient,
    required this.tokenSpecs,
  });

  final OidcClient oidcClient;
  final TokenSpecProvider tokenSpecs;

  @override
  Future<bool> get isAuthenticated async {
    try {
      await token();
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<OidcToken> login({String? tokenId}) {
    TokenSpec? tokenSpec = tokenSpecs.getById(tokenId);
    tokenSpec ??= tokenSpecs.all.first;
    return oidcClient.login(
      scopes: tokenSpec.scopes,
      prompt: LoginPrompt.selectAccount,
    );
  }

  @override
  Future<OidcToken> token({String? tokenId, bool? forceRefresh}) async {
    final tokenSpec = tokenSpecs.getById(tokenId);
    if (tokenSpec == null) {
      throw ArgumentError.value(tokenId, 'tokenId', 'Unknown token id.');
    }
    return oidcClient.getToken(scopes: tokenSpec.scopes, forceRefresh: forceRefresh ?? false);
  }

  @override
  Future<User> user({String? tokenId}) async {
    final oidcToken = await token(tokenId: tokenId);
    final idToken = oidcToken.idToken;
    final name = idToken.payload['preferred_username'] as String;
    final roles = idToken.payload['roles'] as List<dynamic>? ?? [];

    return User(name: name, roles: roles.map((it) => Role.fromName(it)).whereNotNull().toList());
  }

  @override
  Future<void> logout() {
    return oidcClient.logout();
  }

  @override
  Future<void> endSession() {
    return oidcClient.endSession();
  }
}
