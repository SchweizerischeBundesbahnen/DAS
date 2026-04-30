import 'dart:ui';

import 'package:app/model/tour_system.dart';
import 'package:auth/component.dart';
import 'package:logging/logging.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

sealed class Flavor {
  const Flavor({
    required this.displayName,
    required this.mqttUrl,
    required this.authenticatorConfig,
    required this.mqttTopicPrefix,
    required this.backendUrl,
    required this.mqttOauthProfile,
    required this.waraAndroidPackageName,
    required this.waraIOSUrlScheme,
    required this.disablePreload,
    required this.tourSystemUrls,
    this.color = SBBColors.transparent,
    this.showBanner = false,
    this.isTmsEnabledForFlavor = false,
    this.logLevel = Level.INFO,
    this.sferaVersion = 4,
    this.mqttOpenIdProfileMap = const {},
  });

  final String displayName;
  final String mqttUrl;
  final AuthenticatorConfig authenticatorConfig;
  final String mqttTopicPrefix;
  final String mqttOauthProfile;
  final int sferaVersion;
  final Map<String, String> mqttOpenIdProfileMap;
  final String backendUrl;
  final bool showBanner;
  final Color color;
  final bool isTmsEnabledForFlavor;
  final Level logLevel;
  final String waraAndroidPackageName;
  final String waraIOSUrlScheme;
  final bool disablePreload;
  final Map<TourSystem, String> tourSystemUrls;

  factory Flavor.dev() = _DevFlavor;

  factory Flavor.inte() = _InteFlavor;

  factory Flavor.prod() = _ProdFlavor;

  Flavor withSferaMockValues() => switch (this) {
    _DevFlavor() => _DevFlavor(
      mqttUrl: 'wss://das-poc.messaging.solace.cloud',
      authenticatorConfig: _authenticatorConfigDev,
    ),
    _InteFlavor() => _InteFlavor(
      mqttUrl: 'wss://das-poc.messaging.solace.cloud',
      authenticatorConfig: _authenticatorConfigInte,
    ),
    _ProdFlavor() => _ProdFlavor(
      mqttUrl: 'wss://das-poc.messaging.solace.cloud',
      authenticatorConfig: _authenticatorConfigProd,
    ),
  };

  Flavor withTmsValues() => switch (this) {
    _DevFlavor() => _DevFlavor(
      mqttUrl: 'wss://tms-vad-imtrackside-dev-mobile.messaging.solace.cloud',
      authenticatorConfig: _authenticatorConfigDev,
      mqttTopicPrefix: '',
      sferaVersion: 2,
      mqttOpenIdProfileMap: {
        '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a': 'das_sbb_dev',
        'd653d01f-17a4-48a1-9aab-b780b61b4273': 'das_sob_dev',
        'a64ce5df-4ad8-40b9-91ee-54bac2bb8326': 'das_bls_dev',
      },
    ),
    _InteFlavor() => _InteFlavor(
      mqttUrl: 'wss://tms-vad-imtrackside-int-blue-mobile.messaging.solace.cloud',
      authenticatorConfig: _authenticatorConfigInte,
      mqttTopicPrefix: '',
      sferaVersion: 2,
      mqttOpenIdProfileMap: {
        '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a': 'das_sbb_int',
        'd653d01f-17a4-48a1-9aab-b780b61b4273': 'das_sob_int',
        'a64ce5df-4ad8-40b9-91ee-54bac2bb8326': 'das_bls_int',
      },
    ),
    _ProdFlavor() => _ProdFlavor(
      mqttUrl: '',
      authenticatorConfig: _emptyAuthenticatorConfig,
      sferaVersion: 2,
      mqttOpenIdProfileMap: {
        '2cda5d11-f0ac-46b3-967d-af1b2e1bd01a': 'das_sbb_prod',
        'd653d01f-17a4-48a1-9aab-b780b61b4273': 'das_sob_prod',
        'a64ce5df-4ad8-40b9-91ee-54bac2bb8326': 'das_bls_prod',
      },
    ),
  };
}

class _DevFlavor extends Flavor {
  _DevFlavor({
    super.mqttUrl = '',
    super.mqttTopicPrefix = 'dev/',
    super.authenticatorConfig = _emptyAuthenticatorConfig,
    super.disablePreload = false,
    super.sferaVersion,
    super.mqttOpenIdProfileMap,
  }) : super(
         displayName: 'Dev',
         backendUrl: 'das-dev-int.api.sbb.ch',
         color: SBBColors.peach,
         showBanner: true,
         isTmsEnabledForFlavor: true,
         mqttOauthProfile: 'azureAdDev',
         logLevel: Level.FINE,
         waraAndroidPackageName: 'ch.sbb.tms.iad.shas_mobile',
         waraIOSUrlScheme: 'ch.sbb.tms.iad.shasmobile',
         tourSystemUrls: Map.from(_prodTourSystemUrls)..update(.tip, (_) => 'tip3test://tours'),
       );
}

class _InteFlavor extends Flavor {
  const _InteFlavor({
    super.mqttUrl = '',
    super.mqttTopicPrefix = '',
    super.authenticatorConfig = _emptyAuthenticatorConfig,
    super.disablePreload = false,
    super.sferaVersion,
    super.mqttOpenIdProfileMap,
  }) : super(
         displayName: 'Inte',
         backendUrl: 'das-int.api.sbb.ch',
         color: SBBColors.black,
         showBanner: true,
         mqttOauthProfile: 'azureAdInt',
         waraAndroidPackageName: 'ch.sbb.tms.iad.shas_mobile',
         waraIOSUrlScheme: 'ch.sbb.tms.iad.shasmobile',
         tourSystemUrls: _prodTourSystemUrls,
       );
}

class _ProdFlavor extends Flavor {
  const _ProdFlavor({
    super.mqttUrl = '',
    super.mqttTopicPrefix = '',
    super.authenticatorConfig = _emptyAuthenticatorConfig,
    super.disablePreload = false,
    super.sferaVersion,
    super.mqttOpenIdProfileMap,
  }) : super(
         displayName: 'Prod',
         backendUrl: 'das-backend-dev.app.sbb.ch',
         color: SBBColors.transparent,
         showBanner: false,
         mqttOauthProfile: 'azureAdInt',
         waraAndroidPackageName: 'ch.sbb.tms.iad.shas_mobile',
         waraIOSUrlScheme: 'ch.sbb.tms.iad.shasmobile',
         tourSystemUrls: _prodTourSystemUrls,
       );
}

const Map<TourSystem, String> _prodTourSystemUrls = {
  .tip: 'tip3://tours',
  .caros: 'https://sbbc.ivu-cloud.com/mbweb/pub/ivu/desktop/login',
  .railOpt: 'https://railoptweb.sob.ch/personnel-reporting-calendar',
  .railCube: 'play.google.com/store/apps/details?id=com.softlogix.railcube.mobile&hl=en',
  .blsIvu: 'https://ivu.pad.core',
};

const _emptyAuthenticatorConfig = AuthenticatorConfig.empty();

const _authenticatorConfigDev = AuthenticatorConfig(
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
