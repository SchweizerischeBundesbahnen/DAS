import 'package:sbb_oidc/sbb_oidc.dart';

abstract class OidcClientFactory {
  Future<OidcClient> createClient({
    required String tenantId,
    required String clientId,
    required String redirectUrl,
    required String keychainAccessGroup,
  });
}

class const SBBOidcClientFactory() implements OidcClientFactory {
  @override
  Future<OidcClient> createClient({
    required String tenantId,
    required String clientId,
    required String redirectUrl,
    required String keychainAccessGroup,
  }) {
    return SBBOpenIDConnect.createClient(
      config: OidcClientConfig(
        tenantId: tenantId,
        clientId: clientId,
        redirectUrl: redirectUrl,
        keychainAccessGroup: keychainAccessGroup,
      ),
    );
  }
}
