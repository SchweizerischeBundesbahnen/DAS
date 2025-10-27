import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

extension RuExtension on RailwayUndertaking {
  String displayText(BuildContext context) => switch (this) {
    RailwayUndertaking.blsN => context.l10n.c_ru_bls_n,
    RailwayUndertaking.blsP => context.l10n.c_ru_bls_p,
    RailwayUndertaking.blsC => context.l10n.c_ru_bls_c,
    RailwayUndertaking.sbb => context.l10n.c_ru_sbb,
    RailwayUndertaking.sbbP => context.l10n.c_ru_sbb_p,
    RailwayUndertaking.sbbC => context.l10n.c_ru_sbb_c,
    RailwayUndertaking.sbbCInt => context.l10n.c_ru_sbbc_int,
    RailwayUndertaking.sbbD => context.l10n.c_ru_sbb_d,
    RailwayUndertaking.sbbInfraBuildLog => context.l10n.c_ru_sbb_infra_baulog,
    RailwayUndertaking.sbbInfra => context.l10n.c_ru_sbb_infra,
    RailwayUndertaking.sobT => context.l10n.c_ru_sob_t,
    RailwayUndertaking.sobInfra => context.l10n.c_ru_sob_infra,
    RailwayUndertaking.thu => context.l10n.c_ru_thu,
    RailwayUndertaking.ra => context.l10n.c_ru_ra,
    RailwayUndertaking.travys => context.l10n.c_ru_travys,
    RailwayUndertaking.transN => context.l10n.c_ru_transn,
    RailwayUndertaking.tpfInfra => context.l10n.c_ru_tpf_infra,
    RailwayUndertaking.tpfTrafic => context.l10n.c_ru_tpf_trafic,
    RailwayUndertaking.tmr => context.l10n.c_ru_tmr,
    RailwayUndertaking.mbc => context.l10n.c_ru_mbc,
    RailwayUndertaking.unknown => context.l10n.c_unknown,
  };

  String localizedText(AppLocalizations localizations) => switch (this) {
    RailwayUndertaking.blsN => localizations.c_ru_bls_n,
    RailwayUndertaking.blsP => localizations.c_ru_bls_p,
    RailwayUndertaking.blsC => localizations.c_ru_bls_c,
    RailwayUndertaking.sbb => localizations.c_ru_sbb,
    RailwayUndertaking.sbbP => localizations.c_ru_sbb_p,
    RailwayUndertaking.sbbC => localizations.c_ru_sbb_c,
    RailwayUndertaking.sbbCInt => localizations.c_ru_sbbc_int,
    RailwayUndertaking.sbbD => localizations.c_ru_sbb_d,
    RailwayUndertaking.sbbInfraBuildLog => localizations.c_ru_sbb_infra_baulog,
    RailwayUndertaking.sbbInfra => localizations.c_ru_sbb_infra,
    RailwayUndertaking.sobT => localizations.c_ru_sob_t,
    RailwayUndertaking.sobInfra => localizations.c_ru_sob_infra,
    RailwayUndertaking.thu => localizations.c_ru_thu,
    RailwayUndertaking.ra => localizations.c_ru_ra,
    RailwayUndertaking.travys => localizations.c_ru_travys,
    RailwayUndertaking.transN => localizations.c_ru_transn,
    RailwayUndertaking.tpfInfra => localizations.c_ru_tpf_infra,
    RailwayUndertaking.tpfTrafic => localizations.c_ru_tpf_trafic,
    RailwayUndertaking.tmr => localizations.c_ru_tmr,
    RailwayUndertaking.mbc => localizations.c_ru_mbc,
    RailwayUndertaking.unknown => localizations.c_unknown,
  };
}
