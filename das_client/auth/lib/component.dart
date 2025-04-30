import 'package:auth/src/authenticator.dart';
import 'package:auth/src/azure_authenticator.dart';
import 'package:auth/src/token_spec_provider.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

export 'package:auth/src/authenticator.dart';
export 'package:auth/src/authenticator_config.dart';
export 'package:auth/src/token_spec_provider.dart';
export 'package:auth/src/token_spec.dart';
export 'package:auth/src/role.dart';
export 'package:auth/src/user.dart';

class AuthenticationComponent {
  const AuthenticationComponent._();

  static Authenticator createAzureAuthenticator(
      {required OidcClient oidcClient, required TokenSpecProvider tokenSpecs}) {
    return AzureAuthenticator(oidcClient: oidcClient, tokenSpecs: tokenSpecs);
  }
}
