import 'dart:async';

import 'package:auth/component.dart';
import 'package:auth/src/oidc_client_provider.dart';
import 'package:logging/logging.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

final _log = Logger('AzureAuthenticator');

class AzureAuthenticator implements Authenticator {
  AzureAuthenticator({
    required this.config,
    this.oidcClientProvider = const SBBOidcClientProvider(),
  });

  final AuthenticatorConfig config;
  final OidcClientProvider oidcClientProvider;
  late final OidcClient _oidcClient;
  bool isInitialized = false;

  Future<void> _init() async {
    if (isInitialized) return;
    _log.fine('Initialize AzureAuthenticator');
    try {
      _oidcClient = await oidcClientProvider.createClient(
        discoveryUrl: config.discoveryUrl,
        clientId: config.clientId,
        redirectUrl: config.redirectUrl,
        postLogoutRedirectUrl: config.postLogoutRedirectUrl,
      );
      isInitialized = true;
    } catch (e, s) {
      _log.severe('AzureAuthenticator Initialization failed', e, s);
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
    final token = await _oidcClient.login(
      scopes: tokenSpec.scopes,
      prompt: LoginPrompt.selectAccount,
    );

    _validateToken(token);

    return token;
  }

  @override
  Future<OidcToken> token({String? tokenId, bool? forceRefresh}) async {
    await _init();
    final tokenSpec = config.tokenSpecs.getById(tokenId);
    if (tokenSpec == null) {
      throw ArgumentError.value(tokenId, 'tokenId', 'Unknown token id.');
    }

    final token = await _oidcClient.getToken(scopes: tokenSpec.scopes, forceRefresh: forceRefresh ?? false);
    _validateToken(token);

    return token;
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
    return _oidcClient.logout();
  }

  @override
  Future<void> endSession() async {
    await _init();
    return _oidcClient.endSession();
  }

  void _validateToken(OidcToken token) {
    if (!token.isIssuedByTenant(config.trustedTenantIds)) {
      throw Exception('Token issued by untrusted tenant');
    }
  }
}

extension _OidcTokenExtension on OidcToken {
  bool isIssuedByTenant(List<String> trustedIds) {
    final token = JsonWebToken.decode(idToken);
    final tenantId = token.payload['tid'] as String?;
    return tenantId != null && trustedIds.any((id) => id.toLowerCase() == tenantId.toLowerCase());
  }
}
