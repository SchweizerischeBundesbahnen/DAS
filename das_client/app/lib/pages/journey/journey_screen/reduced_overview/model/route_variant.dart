import 'package:app/i18n/i18n.dart';
import 'package:flutter/widgets.dart';

enum RouteVariant({
  required final String fromLocationCode,
  required final String toLocationCode,
  required final String? viaLocationCode,
}) {
  loetschbergViaBergstrecke(
    fromLocationCode: 'CH07478',
    toLocationCode: 'CH01609',
    viaLocationCode: 'CH07475',
  ),
  loetschbergViaBasistunnel(
    fromLocationCode: 'CH07478',
    toLocationCode: 'CH01609',
    viaLocationCode: 'CH15669',
  ),
  nbsBahn2000ViaStammstrecke(
    fromLocationCode: 'CH08103',
    toLocationCode: 'CH08042',
    viaLocationCode: 'CH08144',
  ),
  nbsBahn2000ViaNbs(
    fromLocationCode: 'CH08103',
    toLocationCode: 'CH08042',
    viaLocationCode: 'CH08047',
  ),
  gotthardViaBergstrecke(
    fromLocationCode: 'CH16251',
    toLocationCode: 'CH15717',
    viaLocationCode: 'CH05119',
  ),
  gotthardViaBasistunnel(
    fromLocationCode: 'CH16251',
    toLocationCode: 'CH15717',
    viaLocationCode: 'CH18303',
  ),
  ceneriViaBergstrecke(
    fromLocationCode: 'CH05214',
    toLocationCode: 'CH15720',
    viaLocationCode: 'CH05216',
  ),
  ceneriViaBasistunnel(
    fromLocationCode: 'CH05214',
    toLocationCode: 'CH15720',
    viaLocationCode: 'CH15733',
  ),
  hauensteinViaBergstrecke(
    fromLocationCode: 'CH00026',
    toLocationCode: 'CH00243',
    viaLocationCode: 'CH00035',
  ),
  hauensteinViaBasistunnel(
    fromLocationCode: 'CH00026',
    toLocationCode: 'CH00243',
    viaLocationCode: 'CH00028',
  ),
  eppenbergtunnelViaEppenbergtunnel(
    fromLocationCode: 'CH02111',
    toLocationCode: 'CH02125',
    viaLocationCode: null,
  ),
  eppenbergtunnelViaSchoenenwerd(
    fromLocationCode: 'CH02111',
    toLocationCode: 'CH02125',
    viaLocationCode: 'CH19045',
  ),
  oltenSolothurnViaNbsAbs(
    fromLocationCode: 'CH00218',
    toLocationCode: 'CH00206',
    viaLocationCode: 'CH08103',
  ),
  oltenSolothurnViaOensingen(
    fromLocationCode: 'CH00218',
    toLocationCode: 'CH00206',
    viaLocationCode: 'CH00212',
  ),
  heitersbergViaLenzburgHeitersberg(
    fromLocationCode: 'CH02114',
    toLocationCode: 'CH03506',
    viaLocationCode: 'CH02119',
  ),
  heitersbergViaBruggBaden(
    fromLocationCode: 'CH02114',
    toLocationCode: 'CH03506',
    viaLocationCode: 'CH00309',
  ),
  sargansNord(
    fromLocationCode: 'CH09411',
    toLocationCode: 'CH05362',
    viaLocationCode: null,
  ),
  sargansSued(
    fromLocationCode: 'CH09411',
    toLocationCode: 'CH05362',
    viaLocationCode: 'CH15469',
  ),
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
