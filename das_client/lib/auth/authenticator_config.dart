import 'package:das_client/auth/token_spec_provider.dart';
import 'package:meta/meta.dart';

@sealed
@immutable
class AuthenticatorConfig {
  const AuthenticatorConfig({
    required this.discoveryUrl,
    required this.clientId,
    required this.redirectUrl,
    this.postLogoutRedirectUrl,
    required this.tokenSpecs,
  });

  final String discoveryUrl;
  final String clientId;
  final String redirectUrl;
  final String? postLogoutRedirectUrl;
  final TokenSpecProvider tokenSpecs;

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
