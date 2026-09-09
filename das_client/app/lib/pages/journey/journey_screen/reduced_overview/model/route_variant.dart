import 'package:app/i18n/i18n.dart';
import 'package:flutter/widgets.dart';

enum RouteVariant {
  loetschbergViaBergstrecke(
    bp1LocationCode: 'CH07478',
    bp2LocationCode: 'CH01609',
    bp3LocationCode: 'CH07475',
  ),
  loetschbergViaBasistunnel(
    bp1LocationCode: 'CH07478',
    bp2LocationCode: 'CH01609',
    bp3LocationCode: 'CH15669',
  ),
  nbsBahn2000ViaStammstrecke(
    bp1LocationCode: 'CH08103',
    bp2LocationCode: 'CH08042',
    bp3LocationCode: 'CH08144',
  ),
  nbsBahn2000ViaNbs(
    bp1LocationCode: 'CH08103',
    bp2LocationCode: 'CH08042',
    bp3LocationCode: 'CH08047',
  ),
  gotthardViaBergstrecke(
    bp1LocationCode: 'CH16251',
    bp2LocationCode: 'CH15717',
    bp3LocationCode: 'CH05119',
  ),
  gotthardViaBasistunnel(
    bp1LocationCode: 'CH16251',
    bp2LocationCode: 'CH15717',
    bp3LocationCode: 'CH18303',
  ),
  ceneriViaBergstrecke(
    bp1LocationCode: 'CH05214',
    bp2LocationCode: 'CH15720',
    bp3LocationCode: 'CH05216',
  ),
  ceneriViaBasistunnel(
    bp1LocationCode: 'CH05214',
    bp2LocationCode: 'CH15720',
    bp3LocationCode: 'CH15733',
  ),
  hauensteinViaBergstrecke(
    bp1LocationCode: 'CH00026',
    bp2LocationCode: 'CH00243',
    bp3LocationCode: 'CH00035',
  ),
  hauensteinViaBasistunnel(
    bp1LocationCode: 'CH00026',
    bp2LocationCode: 'CH00243',
    bp3LocationCode: 'CH00028',
  ),
  eppenbergtunnelViaEppenbergtunnel(
    bp1LocationCode: 'CH02111',
    bp2LocationCode: 'CH02125',
    bp3LocationCode: null,
  ),
  eppenbergtunnelViaSchoenenwerd(
    bp1LocationCode: 'CH02111',
    bp2LocationCode: 'CH02125',
    bp3LocationCode: 'CH19045',
  ),
  oltenSolothurnViaNbsAbs(
    bp1LocationCode: 'CH00218',
    bp2LocationCode: 'CH00206',
    bp3LocationCode: 'CH08103',
  ),
  oltenSolothurnViaOensingen(
    bp1LocationCode: 'CH00218',
    bp2LocationCode: 'CH00206',
    bp3LocationCode: 'CH00212',
  ),
  heitersbergViaLenzburgHeitersberg(
    bp1LocationCode: 'CH02114',
    bp2LocationCode: 'CH03506',
    bp3LocationCode: 'CH02119',
  ),
  heitersbergViaBruggBaden(
    bp1LocationCode: 'CH02114',
    bp2LocationCode: 'CH03506',
    bp3LocationCode: 'CH00309',
  ),
  sargansNord(
    bp1LocationCode: 'CH09411',
    bp2LocationCode: 'CH05362',
    bp3LocationCode: null,
  ),
  sargansSued(
    bp1LocationCode: 'CH09411',
    bp2LocationCode: 'CH05362',
    bp3LocationCode: 'CH15469',
  );

  RouteVariant({
    required this.bp1LocationCode,
    required this.bp2LocationCode,
    required this.bp3LocationCode,
  });

  final String bp1LocationCode;
  final String bp2LocationCode;
  final String? bp3LocationCode;
}

extension RouteVariantX on RouteVariant {
  String localizedName(BuildContext context) => switch (this) {
    RouteVariant.loetschbergViaBergstrecke => context.l10n.w_route_variant_loetschberg_via_bergstrecke,
    RouteVariant.loetschbergViaBasistunnel => context.l10n.w_route_variant_loetschberg_via_basistunnel,
    RouteVariant.nbsBahn2000ViaStammstrecke => context.l10n.w_route_variant_nbs_bahn_2000_via_stammstrecke,
    RouteVariant.nbsBahn2000ViaNbs => context.l10n.w_route_variant_nbs_bahn_2000_via_nbs,
    RouteVariant.gotthardViaBergstrecke => context.l10n.w_route_variant_gotthard_via_bergstrecke,
    RouteVariant.gotthardViaBasistunnel => context.l10n.w_route_variant_gotthard_via_basistunnel,
    RouteVariant.ceneriViaBergstrecke => context.l10n.w_route_variant_ceneri_via_bergstrecke,
    RouteVariant.ceneriViaBasistunnel => context.l10n.w_route_variant_ceneri_via_basistunnel,
    RouteVariant.hauensteinViaBergstrecke => context.l10n.w_route_variant_hauenstein_via_bergstrecke,
    RouteVariant.hauensteinViaBasistunnel => context.l10n.w_route_variant_hauenstein_via_basistunnel,
    RouteVariant.eppenbergtunnelViaEppenbergtunnel => context.l10n.w_route_variant_eppenbergtunnel_via_eppenbergtunnel,
    RouteVariant.eppenbergtunnelViaSchoenenwerd => context.l10n.w_route_variant_eppenbergtunnel_via_schoenenwerd,
    RouteVariant.oltenSolothurnViaNbsAbs => context.l10n.w_route_variant_olten_solothurn_via_nbs_abs,
    RouteVariant.oltenSolothurnViaOensingen => context.l10n.w_route_variant_olten_solothurn_via_oensingen,
    RouteVariant.heitersbergViaLenzburgHeitersberg => context.l10n.w_route_variant_heitersberg_via_lenzburg_heitersberg,
    RouteVariant.heitersbergViaBruggBaden => context.l10n.w_route_variant_heitersberg_via_brugg_baden,
    RouteVariant.sargansNord => context.l10n.w_route_variant_sargans_nord,
    RouteVariant.sargansSued => context.l10n.w_route_variant_sargans_sued,
  };
}
