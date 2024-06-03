import 'package:das_client/auth/authenticator_config.dart';
import 'package:das_client/auth/token_spec.dart';
import 'package:das_client/auth/token_spec_provider.dart';
import 'package:sbb_oidc/sbb_oidc.dart';

enum Flavor {
  dev(
    displayName: 'Dev',
    authenticatorConfig: _authenticatorConfigDev,
  );

  const Flavor({
    required this.displayName,
    required this.authenticatorConfig,
  });

  final String displayName;
  final AuthenticatorConfig authenticatorConfig;
}

const _authenticatorConfigDev = AuthenticatorConfig(
  discoveryUrl: SBBDiscoveryUrl.prod,
  clientId: '6025180f-123b-4f2f-9703-16e08fc221f0',
  redirectUrl: 'ch.sbb.das://sbbauth/redirect',
  tokenSpecs: TokenSpecProvider([
    TokenSpec(
      id: 'T1',
      displayName: 'Token 1',
      scopes: [
        'openid',
        'profile',
        'email',
        'offline_access',
        'User.Read',
      ],
    ),
  ]),
);
