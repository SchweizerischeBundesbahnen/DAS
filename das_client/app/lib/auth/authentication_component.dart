import 'package:app/auth/src/authenticator.dart';
import 'package:app/auth/src/azure_authenticator.dart';
import 'package:app/auth/src/token_spec_provider.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

export 'package:app/auth/src/auth_cubit.dart';
export 'package:app/auth/src/authenticator.dart';
export 'package:app/auth/src/authenticator_config.dart';
export 'package:app/auth/src/token_spec_provider.dart';
export 'package:app/auth/src/token_spec.dart';
export 'package:app/auth/src/role.dart';
export 'package:app/auth/src/user.dart';

class AuthenticationComponent {
  const AuthenticationComponent._();

  static Authenticator createAzureAuthenticator(
      {required OidcClient oidcClient, required TokenSpecProvider tokenSpecs}) {
    return AzureAuthenticator(oidcClient: oidcClient, tokenSpecs: tokenSpecs);
  }
}
