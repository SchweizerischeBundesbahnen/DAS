/// Thrown when an OidcToken fails validation in AzureAuthenticator.
class const InvalidTokenException(final String message) implements Exception {
  factory missingIdToken() => InvalidTokenException('Token does not contain an ID token');

  factory untrustedTenant(String? tenantId) => InvalidTokenException('Token issued by untrusted tenant "$tenantId"');

  factory disallowedRoles(List<String> roles) =>
      InvalidTokenException('Token roles $roles do not contain any allowed role');

  @override
  String toString() => 'InvalidTokenException: $message';
}
