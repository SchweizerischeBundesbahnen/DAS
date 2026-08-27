import 'package:sbb_oidc/sbb_oidc.dart';

abstract class OidcClientFactory {
  Future<OidcClient> createClient({
    required String discoveryUrl,
    required String clientId,
    required String redirectUrl,
    String? postLogoutRedirectUrl,
  });
}

class const SBBOidcClientFactory() implements OidcClientFactory {
  @override
  Future<OidcClient> createClient({
    required String discoveryUrl,
    required String clientId,
    required String redirectUrl,
    String? postLogoutRedirectUrl,
  }) {
    return SBBOpenIDConnect.createClient(
      discoveryUrl: discoveryUrl,
      clientId: clientId,
      redirectUrl: redirectUrl,
      postLogoutRedirectUrl: postLogoutRedirectUrl,
      tokenAccessibility: TokenAccessibility.afterFirstUnlockThisDeviceOnly,
    );
  }
}
