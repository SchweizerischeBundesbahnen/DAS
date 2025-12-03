import 'package:sbb_oidc/sbb_oidc.dart';

abstract class OidcClientProvider {
  Future<OidcClient> createClient({
    required String discoveryUrl,
    required String clientId,
    required String redirectUrl,
    String? postLogoutRedirectUrl,
  });
}

class SBBOidcClientProvider implements OidcClientProvider {
  const SBBOidcClientProvider();

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
    );
  }
}
