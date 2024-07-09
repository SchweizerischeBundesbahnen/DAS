import 'dart:async';

import 'package:das_client/auth/authenticator.dart';
import 'package:das_client/auth/token_spec.dart';
import 'package:das_client/auth/token_spec_provider.dart';
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
  Future<OidcToken> token({String? tokenId}) async {
    final tokenSpec = tokenSpecs.getById(tokenId);
    if (tokenSpec == null) {
      throw ArgumentError.value(tokenId, 'tokenId', 'Unknown token id.');
    }
    return oidcClient.getToken(scopes: tokenSpec.scopes, forceRefresh: true);
  }

  @override
  Future<String> userId({String? tokenId}) async {
    final oidcToken = await token(tokenId: tokenId);
    final idToken = oidcToken.idToken;
    return idToken.payload['sbbuid'] as String;
  }

  @override
  Future<UserInfo> userInfo() async {
    final tokenSpec = tokenSpecs.first;
    return oidcClient.getUserInfo(scopes: tokenSpec.scopes);
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
