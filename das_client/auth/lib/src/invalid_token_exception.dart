/// Thrown when an OidcToken fails validation in AzureAuthenticator.
class InvalidTokenException implements Exception {
  const InvalidTokenException(this.message);

  factory InvalidTokenException.untrustedTenant(String? tenantId) =>
      InvalidTokenException('Token issued by untrusted tenant "$tenantId"');

  factory InvalidTokenException.disallowedRoles(List<String> roles) =>
      InvalidTokenException('Token roles $roles do not contain any allowed role');

  final String message;

  @override
  String toString() => 'InvalidTokenException: $message';
}
