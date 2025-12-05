import 'package:auth/src/token_spec_provider.dart';
import 'package:meta/meta.dart';

const sbbTenantId = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a';
const blsTenantId = 'd653d01f-17a4-48a1-9aab-b780b61b4273';
const sobTenantId = 'a64ce5df-4ad8-40b9-91ee-54bac2bb8326';

@sealed
@immutable
class AuthenticatorConfig {
  const AuthenticatorConfig({
    required this.discoveryUrl,
    required this.clientId,
    required this.redirectUrl,
    required this.tokenSpecs,
    this.postLogoutRedirectUrl,
    this.trustedTenantIds = const [sbbTenantId, blsTenantId, sobTenantId],
  });

  const AuthenticatorConfig.empty()
    : discoveryUrl = '',
      clientId = '',
      redirectUrl = '',
      postLogoutRedirectUrl = null,
      tokenSpecs = const TokenSpecProvider.empty(),
      trustedTenantIds = const [];

  final String discoveryUrl;
  final String clientId;
  final String redirectUrl;
  final String? postLogoutRedirectUrl;
  final TokenSpecProvider tokenSpecs;

  /// list of trusted tenants that are validated in token claim
  final List<String> trustedTenantIds;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthenticatorConfig &&
        other.discoveryUrl == discoveryUrl &&
        other.clientId == clientId &&
        other.redirectUrl == redirectUrl &&
        other.postLogoutRedirectUrl == postLogoutRedirectUrl &&
        other.tokenSpecs == tokenSpecs;
  }

  @override
  int get hashCode {
    return Object.hash(
      discoveryUrl,
      clientId,
      redirectUrl,
      postLogoutRedirectUrl,
      tokenSpecs,
    );
  }
}
