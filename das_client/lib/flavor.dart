import 'package:das_client/auth/authenticator_config.dart';
import 'package:das_client/auth/token_spec.dart';
import 'package:das_client/auth/token_spec_provider.dart';

enum Flavor {
  dev(
    displayName: 'Dev',
    tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
    tmsTokenExchangeUrl: 'https://imts-token-provider-tms-vad-imtrackside-dev.apps.halon-ocp1-1-t.sbb-aws-test.net/token/exchange',
    mqttUrl: 'wss://das-poc.messaging.solace.cloud',
    tmsMqttUrl: 'wss://tms-vad-imtrackside-dev-mobile.messaging.solace.cloud',
    authenticatorConfig: _authenticatorConfigMockDev,
    tmsAuthenticatorConfig: _authenticatorConfigTmsDev,
  ),
  inte(
    displayName: 'Inte',
    tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
    mqttUrl: 'wss://das-poc.messaging.solace.cloud',
    authenticatorConfig: _authenticatorConfigInte,
  ),
  prod(
    displayName: 'Prod',
    tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
    mqttUrl: 'wss://das-poc.messaging.solace.cloud',
    authenticatorConfig: _authenticatorConfigProd,
  );

  const Flavor({
    required this.displayName,
    required this.tokenExchangeUrl,
    this.tmsTokenExchangeUrl,
    required this.mqttUrl,
    this.tmsMqttUrl,
    required this.authenticatorConfig,
    this.tmsAuthenticatorConfig,
  });

  final String displayName;
  final String tokenExchangeUrl;
  final String? tmsTokenExchangeUrl;
  final String mqttUrl;
  final String? tmsMqttUrl;
  final AuthenticatorConfig authenticatorConfig;
  final AuthenticatorConfig? tmsAuthenticatorConfig;
}


const _authenticatorConfigTmsDev = AuthenticatorConfig(
  discoveryUrl: "https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/v2.0/.well-known/openid-configuration",
  clientId: '8af8281c-4f1d-47b5-ad77-526b1da61b2b',
  redirectUrl: 'ch.sbb.das://sbbauth/redirect',
  tokenSpecs: TokenSpecProvider([
    TokenSpec(
      id: TokenSpec.defaultTokenId,
      displayName: 'User Token',
      scopes: ['openid', 'profile', 'email', 'offline_access', '8af8281c-4f1d-47b5-ad77-526b1da61b2b/.default'],
    ),
  ]),
);

const _authenticatorConfigMockDev = AuthenticatorConfig(
  discoveryUrl: "https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration",
  clientId: '6025180f-123b-4f2f-9703-16e08fc221f0',
  redirectUrl: 'ch.sbb.das://sbbauth/redirect',
  tokenSpecs: TokenSpecProvider([
    TokenSpec(
      id: TokenSpec.defaultTokenId,
      displayName: 'User Token',
      scopes: ['openid', 'profile', 'email', 'offline_access', '6025180f-123b-4f2f-9703-16e08fc221f0/.default'],
    ),
  ]),
);

const _authenticatorConfigInte = AuthenticatorConfig(
  discoveryUrl: "https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration",
  clientId: '6025180f-123b-4f2f-9703-16e08fc221f0',
  redirectUrl: 'ch.sbb.das://sbbauth/redirect',
  tokenSpecs: TokenSpecProvider([
    TokenSpec(
      id: TokenSpec.defaultTokenId,
      displayName: 'User Token',
      scopes: ['openid', 'profile', 'email', 'offline_access', '6025180f-123b-4f2f-9703-16e08fc221f0/.default'],
    ),
  ]),
);

const _authenticatorConfigProd = AuthenticatorConfig(
  discoveryUrl: "https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration",
  clientId: '6025180f-123b-4f2f-9703-16e08fc221f0',
  redirectUrl: 'ch.sbb.das://sbbauth/redirect',
  tokenSpecs: TokenSpecProvider([
    TokenSpec(
      id: TokenSpec.defaultTokenId,
      displayName: 'User Token',
      scopes: ['openid', 'profile', 'email', 'offline_access', '6025180f-123b-4f2f-9703-16e08fc221f0/.default'],
    ),
  ]),
);
