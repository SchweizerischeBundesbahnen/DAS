import 'dart:async';

import 'package:auth/component.dart';
import 'package:fimber/fimber.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

class AzureAuthenticator implements Authenticator {
  AzureAuthenticator({required this.config});

  final AuthenticatorConfig config;
  late final OidcClient oidcClient;
  bool isInitialized = false;

  Future<void> _init() async {
    if (isInitialized) return;
    Fimber.d('Initialize AzureAuthenticator');
    try {
      oidcClient = await SBBOpenIDConnect.createClient(
        discoveryUrl: config.discoveryUrl,
        clientId: config.clientId,
        redirectUrl: config.redirectUrl,
        postLogoutRedirectUrl: config.postLogoutRedirectUrl,
      );
      isInitialized = true;
    } catch (e, s) {
      Fimber.e('AzureAuthenticator Initialization failed', ex: e, stacktrace: s);
      rethrow;
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    await _init();
    try {
      await token();
      return true;
    } catch (e) {
      // Delete all existing tokens. They are invalid and might cause issues.
      await logout();
      return false;
    }
  }

  @override
  Future<OidcToken> login({String? tokenId}) async {
    await _init();
    TokenSpec? tokenSpec = config.tokenSpecs.getById(tokenId);
    tokenSpec ??= config.tokenSpecs.all.first;
    return oidcClient.login(
      scopes: tokenSpec.scopes,
      prompt: LoginPrompt.selectAccount,
    );
  }

  @override
  Future<OidcToken> token({String? tokenId, bool? forceRefresh}) async {
    await _init();
    final tokenSpec = config.tokenSpecs.getById(tokenId);
    if (tokenSpec == null) {
      throw ArgumentError.value(tokenId, 'tokenId', 'Unknown token id.');
    }
    return oidcClient.getToken(scopes: tokenSpec.scopes, forceRefresh: forceRefresh ?? false);
  }

  @override
  Future<User> user({String? tokenId}) async {
    await _init();
    final oidcToken = await token(tokenId: tokenId);
    final idToken = JsonWebToken.decode(oidcToken.idToken);
    final name = idToken.payload['preferred_username'] as String;
    final roles = idToken.payload['roles'] as List<dynamic>? ?? [];

    return User(name: name, roles: roles.map((it) => Role.fromName(it)).nonNulls.toList());
  }

  @override
  Future<void> logout() async {
    await _init();
    return oidcClient.logout();
  }

  @override
  Future<void> endSession() async {
    await _init();
    return oidcClient.endSession();
  }
}
