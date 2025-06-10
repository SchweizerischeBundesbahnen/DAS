import 'dart:ui';

import 'package:auth/component.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

sealed class Flavor {
  const Flavor({
    required this.displayName,
    required this.tokenExchangeUrl,
    required this.mqttUrl,
    required this.authenticatorConfig,
    required this.mqttTopicPrefix,
    required this.backendUrl,
    required this.mqttOauthProfile,
    this.color = SBBColors.transparent,
    this.showBanner = false,
    this.isTmsEnabledForFlavor = false,
  });

  final String displayName;
  final String tokenExchangeUrl;
  final String mqttUrl;
  final AuthenticatorConfig authenticatorConfig;
  final String mqttTopicPrefix;
  final String mqttOauthProfile;
  final String backendUrl;
  final bool showBanner;
  final Color color;
  final bool isTmsEnabledForFlavor;

  factory Flavor.dev() = _DevFlavor;

  factory Flavor.inte() = _InteFlavor;

  factory Flavor.prod() = _ProdFlavor;

  Flavor withSferaMockValues() {
    switch (this) {
      case _DevFlavor():
        return _DevFlavor(
          tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
          mqttUrl: 'wss://das-poc.messaging.solace.cloud',
          authenticatorConfig: _authenticatorConfigMockDev,
        );
      case _InteFlavor():
        return _InteFlavor(
          tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
          mqttUrl: 'wss://das-poc.messaging.solace.cloud',
          authenticatorConfig: _authenticatorConfigInte,
        );
      case _ProdFlavor():
        return _ProdFlavor(
          tokenExchangeUrl: 'https://sfera-mock.app.sbb.ch/customClaim/requestToken',
          mqttUrl: 'wss://das-poc.messaging.solace.cloud',
          authenticatorConfig: _authenticatorConfigProd,
        );
    }
  }

  Flavor withTmsValues() {
    switch (this) {
      case _DevFlavor():
        return _DevFlavor(
          tokenExchangeUrl:
              'https://imts-token-provider-tms-vad-imtrackside-dev.apps.halon-ocp1-1-t.sbb-aws-test.net/token/exchange',
          mqttUrl: 'wss://das-poc.messaging.solace.cloudwss://tms-vad-imtrackside-dev-mobile.messaging.solace.cloud',
          authenticatorConfig: _authenticatorConfigTmsDev,
        );
      case _InteFlavor():
        return _InteFlavor(
          tokenExchangeUrl: '',
          mqttUrl: '',
          authenticatorConfig: _emptyAuthenticatorConfig,
        );
      case _ProdFlavor():
        return _ProdFlavor(
          tokenExchangeUrl: '',
          mqttUrl: '',
          authenticatorConfig: _emptyAuthenticatorConfig,
        );
    }
  }
}

class _DevFlavor extends Flavor {
  const _DevFlavor({
    super.tokenExchangeUrl = '',
    super.mqttUrl = '',
    super.authenticatorConfig = _emptyAuthenticatorConfig,
  }) : super(
         displayName: 'Dev',
         mqttTopicPrefix: 'dev/',
         backendUrl: 'das-backend-dev.app.sbb.ch',
         color: SBBColors.peach,
         showBanner: true,
         isTmsEnabledForFlavor: true,
    mqttOauthProfile: 'azureAdDev',
       );
}

class _InteFlavor extends Flavor {
  const _InteFlavor({
    super.tokenExchangeUrl = '',
    super.mqttUrl = '',
    super.authenticatorConfig = _emptyAuthenticatorConfig,
  }) : super(
         displayName: 'Inte',
         mqttTopicPrefix: '',
         backendUrl: 'das-backend-int.app.sbb.ch',
         color: SBBColors.black,
         showBanner: true,
    mqttOauthProfile: 'azureAdInt',
       );
}

class _ProdFlavor extends Flavor {
  const _ProdFlavor({
    super.tokenExchangeUrl = '',
    super.mqttUrl = '',
    super.authenticatorConfig = _emptyAuthenticatorConfig,
  }) : super(
         displayName: 'Prod',
         mqttTopicPrefix: '',
         backendUrl: 'das-backend-dev.app.sbb.ch',
         color: SBBColors.transparent,
         showBanner: false,
    mqttOauthProfile: 'azureAdInt',
       );
}

const _emptyAuthenticatorConfig = AuthenticatorConfig.empty();

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
  clientId: '5467e91f-a84c-40a5-89ba-75dcefc5569c',
  redirectUrl: 'ch.sbb.das://sbbauth/redirect',
  tokenSpecs: TokenSpecProvider([
    TokenSpec(
      id: TokenSpec.defaultTokenId,
      displayName: 'User Token',
      scopes: ['openid', 'profile', 'email', 'offline_access', 'api://8f16d52b-c6df-4a94-a132-da4956579a48/.default'],
    ),
  ]),
);

const _authenticatorConfigInte = AuthenticatorConfig(
  discoveryUrl: 'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
  clientId: '7d1cf8b6-a770-422f-ae8b-a9cbfe63e7b9',
  redirectUrl: 'ch.sbb.das://sbbauth/redirect',
  tokenSpecs: TokenSpecProvider([
    TokenSpec(
      id: TokenSpec.defaultTokenId,
      displayName: 'User Token',
      scopes: ['openid', 'profile', 'email', 'offline_access', 'api://c46d2363-2b94-439a-a84d-f71a76a70f45/.default'],
    ),
  ]),
);

const _authenticatorConfigProd = AuthenticatorConfig(
  discoveryUrl: 'https://login.microsoftonline.com/common/v2.0/.well-known/openid-configuration',
  clientId: '7d1cf8b6-a770-422f-ae8b-a9cbfe63e7b9',
  redirectUrl: 'ch.sbb.das://sbbauth/redirect',
  tokenSpecs: TokenSpecProvider([
    TokenSpec(
      id: TokenSpec.defaultTokenId,
      displayName: 'User Token',
      scopes: ['openid', 'profile', 'email', 'offline_access', 'api://c46d2363-2b94-439a-a84d-f71a76a70f45/.default'],
    ),
  ]),
);
