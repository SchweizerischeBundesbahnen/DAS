import 'package:auth/component.dart';
import 'package:meta/meta.dart';

const sbbTenantId = '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a';
const blsTenantId = 'd653d01f-17a4-48a1-9aab-b780b61b4273';
const sobTenantId = 'a64ce5df-4ad8-40b9-91ee-54bac2bb8326';

@sealed
@immutable
class const AuthenticatorConfig({
  required final String tenantId,
  required final String clientId,
  required final String redirectUrl,
  required final String keychainAccessGroup,
  required final TokenSpecProvider tokenSpecs,

  /// list of trusted tenants that are validated in token claim
  final List<String> trustedTenantIds = const [sbbTenantId, blsTenantId, sobTenantId],

  /// list of roles, at least one of which must be present in the token claim
  final List<Role> allowedRoles = const [Role.driver, Role.observer],
}) {
  const AuthenticatorConfig.empty()
    : this(
        tenantId: '',
        clientId: '',
        redirectUrl: '',
        keychainAccessGroup: '',
        tokenSpecs: const TokenSpecProvider.empty(),
        trustedTenantIds: const [],
        allowedRoles: const [],
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthenticatorConfig &&
        other.tenantId == tenantId &&
        other.clientId == clientId &&
        other.redirectUrl == redirectUrl &&
        other.keychainAccessGroup == keychainAccessGroup &&
        other.tokenSpecs == tokenSpecs;
  }

  @override
  int get hashCode {
    return Object.hash(
      tenantId,
      clientId,
      redirectUrl,
      keychainAccessGroup,
      tokenSpecs,
    );
  }
}
