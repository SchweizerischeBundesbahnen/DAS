import 'dart:async';

import 'package:auth/component.dart';
import 'package:auth/src/oidc_client_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

final _log = Logger('AzureAuthenticator');

class AzureAuthenticator implements Authenticator {
  static const _offlineTokenValidityDuration = Duration(days: 1);

  AzureAuthenticator({
    required AuthenticatorConfig config,
    OidcClientFactory oidcClientFactory = const SBBOidcClientFactory(),
    FlutterSecureStorage storage = const FlutterSecureStorage(
      iOptions: IOSOptions(accountName: 'auth'),
      aOptions: AndroidOptions(sharedPreferencesName: 'auth'),
    ),
  }) : _config = config,
       _oidcClientFactory = oidcClientFactory,
       _storage = storage;

  final AuthenticatorConfig _config;
  final OidcClientFactory _oidcClientFactory;
  late final OidcClient _oidcClient;
  final FlutterSecureStorage _storage;
  bool _isInitialized = false;
  final _reauthenticationRequiredSubject = BehaviorSubject.seeded(false);

  Future<void> _init() async {
    if (_isInitialized) return;
    _log.fine('Initialize AzureAuthenticator');
    try {
      _oidcClient = await _oidcClientFactory.createClient(
        discoveryUrl: _config.discoveryUrl,
        clientId: _config.clientId,
        redirectUrl: _config.redirectUrl,
        postLogoutRedirectUrl: _config.postLogoutRedirectUrl,
      );
      _isInitialized = true;
    } catch (e, s) {
      _log.severe('AzureAuthenticator Initialization failed', e, s);
      rethrow;
    }
  }

  @override
  Future<bool> get isAuthenticated async {
    try {
      await token();
      return true;
    } catch (e) {
      if (_isInitialized) {
        // Delete all existing tokens. They are invalid and might cause issues.
        await logout();
      }
      return false;
    }
  }

  @override
  Future<OidcToken> login({String? tokenId}) async {
    try {
      await _init();
      TokenSpec? tokenSpec = _config.tokenSpecs.getById(tokenId);
      tokenSpec ??= _config.tokenSpecs.all.first;
      final token = await _oidcClient.login(
        scopes: tokenSpec.scopes,
        prompt: LoginPrompt.selectAccount,
      );
      _validateToken(token);
      _updateReauthenticationRequiredState(false);
      _writeOfflineToken(token: token, tokenId: tokenId);

      return token;
    } catch (e) {
      if (!_isNetworkError(e)) {
        _log.info('Failed to retrieve new token on login, reauthentication required', e);
        _updateReauthenticationRequiredState(true);
      }

      final token = await _loadOfflineToken(tokenId: tokenId);
      if (token != null) {
        _validateToken(token);
        _log.info('Login failed, but found valid offline token. Using it as fallback.');
        return token;
      }
      rethrow;
    }
  }

  @override
  Future<OidcToken> token({String? tokenId, bool? forceRefresh}) async {
    try {
      await _init();
      final tokenSpec = _config.tokenSpecs.getById(tokenId);
      if (tokenSpec == null) {
        throw ArgumentError.value(tokenId, 'tokenId', 'Unknown token id.');
      }

      final token = await _oidcClient.getToken(scopes: tokenSpec.scopes, forceRefresh: forceRefresh ?? false);
      _validateToken(token);
      _updateReauthenticationRequiredState(false);
      _writeOfflineToken(token: token, tokenId: tokenId);

      return token;
    } catch (e) {
      if (!_isNetworkError(e)) {
        _log.info('Failed to retrieve new token, reauthentication required', e);
        _updateReauthenticationRequiredState(true);
      }

      final token = await _loadOfflineToken(tokenId: tokenId);
      if (token != null) {
        _validateToken(token);
        _log.info('Found valid offline token. Using it as fallback.');
        return token;
      }
      rethrow;
    }
  }

  bool _isNetworkError(dynamic e) {
    if (e is NetworkException) return true;

    final message = e.toString();
    if (message.contains('Connection error')) return true;

    return false;
  }

  @override
  Future<User> user({String? tokenId}) async {
    OidcToken? oidcToken;
    try {
      await _init();
      oidcToken = await token(tokenId: tokenId);
    } catch (e) {
      oidcToken = await _loadOfflineToken(tokenId: tokenId);
      if (oidcToken == null) {
        rethrow;
      }
    }
    final idToken = JsonWebToken.decode(oidcToken.idToken);
    final userId = idToken.payload['preferred_username'] as String;
    final roles = idToken.payload['roles'] as List<dynamic>? ?? [];
    final displayName = idToken.payload['name'] as String?;
    final tid = idToken.payload['tid'] as String?;

    return User(
      userId: userId,
      roles: roles.map((it) => Role.fromName(it)).nonNulls.toList(),
      displayName: displayName,
      tid: tid,
    );
  }

  void _updateReauthenticationRequiredState(bool state) {
    if (_reauthenticationRequiredSubject.value != state) {
      _log.info('Updating reauthentication required state to $state');
      _reauthenticationRequiredSubject.add(state);
    }
  }

  @override
  Future<void> logout() async {
    await _init();
    await _storage.deleteAll();
    return _oidcClient.logout();
  }

  @override
  Future<void> endSession() async {
    await _init();
    await _storage.deleteAll();
    return _oidcClient.endSession();
  }

  Future<OidcToken?> _loadOfflineToken({String? tokenId}) async {
    final key = tokenId ?? TokenSpec.defaultTokenId;

    final tokenPayload = await _storage.read(key: key);
    if (tokenPayload == null) return null;

    final oidcToken = OidcToken.fromJsonString(tokenPayload);
    if (_isExpiredMoreThanOfflineValidityDuration(oidcToken)) {
      await _storage.delete(key: key);
      return null;
    }

    return oidcToken;
  }

  bool _isExpiredMoreThanOfflineValidityDuration(OidcToken oidcToken) {
    return oidcToken.accessTokenExpirationDateTime == null ||
        oidcToken.accessTokenExpirationDateTime!.isBefore(DateTime.now().subtract(_offlineTokenValidityDuration));
  }

  Future<void> _writeOfflineToken({required OidcToken token, String? tokenId}) {
    return _storage.write(key: tokenId ?? TokenSpec.defaultTokenId, value: token.toJsonString());
  }

  void _validateToken(OidcToken token) {
    if (!token.isIssuedByTenant(_config.trustedTenantIds)) {
      throw Exception('Token issued by untrusted tenant');
    }
  }

  @override
  Stream<bool> get reauthenticationRequired => _reauthenticationRequiredSubject.distinct();
}

extension _OidcTokenExtension on OidcToken {
  bool isIssuedByTenant(List<String> trustedIds) {
    final token = JsonWebToken.decode(idToken);
    final tenantId = token.payload['tid'] as String?;
    return tenantId != null && trustedIds.any((id) => id.toLowerCase() == tenantId.toLowerCase());
  }
}
