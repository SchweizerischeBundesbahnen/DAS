import 'package:auth/component.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

enum Flavor {
  dev(
    displayName: 'Dev',
    tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
    tmsTokenExchangeUrl:
        'https://imts-token-provider-tms-vad-imtrackside-dev.apps.halon-ocp1-1-t.sbb-aws-test.net/token/exchange',
    mqttUrl: 'wss://das-poc.messaging.solace.cloud',
    tmsMqttUrl: 'wss://tms-vad-imtrackside-dev-mobile.messaging.solace.cloud',
    authenticatorConfig: _authenticatorConfigMockDev,
    tmsAuthenticatorConfig: _authenticatorConfigTmsDev,
    backendUrl: 'das-backend-dev.app.sbb.ch',
    mqttTopicPrefix: 'dev/',
    color: SBBColors.peach,
    showBanner: true,
  ),
  inte(
    displayName: 'Inte',
    tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
    mqttUrl: 'wss://das-poc.messaging.solace.cloud',
    authenticatorConfig: _authenticatorConfigInte,
    backendUrl: 'das-backend-int.app.sbb.ch',
    mqttTopicPrefix: '',
    color: SBBColors.black,
    showBanner: true,
  ),
  prod(
    displayName: 'Prod',
    tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
    mqttUrl: 'wss://das-poc.messaging.solace.cloud',
    authenticatorConfig: _authenticatorConfigProd,
    backendUrl: 'das-backend-dev.app.sbb.ch',
    mqttTopicPrefix: '',
  );

  const Flavor({
    required this.displayName,
    required this.tokenExchangeUrl,
    required this.mqttUrl,
    required this.authenticatorConfig,
    required this.mqttTopicPrefix,
    required this.backendUrl,
    this.color = SBBColors.transparent,
    this.showBanner = false,
    this.tmsTokenExchangeUrl,
    this.tmsMqttUrl,
    this.tmsAuthenticatorConfig,
  });

  final String displayName;
  final String tokenExchangeUrl;
  final String? tmsTokenExchangeUrl;
  final String mqttUrl;
  final String? tmsMqttUrl;
  final AuthenticatorConfig authenticatorConfig;
  final AuthenticatorConfig? tmsAuthenticatorConfig;
  final String mqttTopicPrefix;
  final String backendUrl;
  final bool showBanner;
  final Color color;
}

const _authenticatorConfigTmsDev = AuthenticatorConfig(
  discoveryUrl:
      'https://login.microsoftonline.com/2cda5d11-f0ac-46b3-967d-af1b2e1bd01a/v2.0/.well-known/openid-configuration',
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
  discoveryUrl: 'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
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
  discoveryUrl: 'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
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
  discoveryUrl: 'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
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
