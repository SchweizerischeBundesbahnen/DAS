import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

extension RuExtension on RailwayUndertaking {
  String displayText(BuildContext context) => switch (this) {
    .blsN => context.l10n.c_ru_bls_n,
    .blsP => context.l10n.c_ru_bls_p,
    .blsC => context.l10n.c_ru_bls_c,
    .sbb => context.l10n.c_ru_sbb,
    .sbbP => context.l10n.c_ru_sbb_p,
    .sbbC => context.l10n.c_ru_sbb_c,
    .sbbCInt => context.l10n.c_ru_sbbc_int,
    .sbbD => context.l10n.c_ru_sbb_d,
    .sbbInfraBuildLog => context.l10n.c_ru_sbb_infra_baulog,
    .sbbInfra => context.l10n.c_ru_sbb_infra,
    .sobT => context.l10n.c_ru_sob_t,
    .sobInfra => context.l10n.c_ru_sob_infra,
    .thu => context.l10n.c_ru_thu,
    .ra => context.l10n.c_ru_ra,
    .travys => context.l10n.c_ru_travys,
    .transN => context.l10n.c_ru_transn,
    .tpfInfra => context.l10n.c_ru_tpf_infra,
    .tpfTrafic => context.l10n.c_ru_tpf_trafic,
    .tmr => context.l10n.c_ru_tmr,
    .mbc => context.l10n.c_ru_mbc,
    .unknown => context.l10n.c_unknown,
  };

  String localizedText(AppLocalizations localizations) => switch (this) {
    .blsN => localizations.c_ru_bls_n,
    .blsP => localizations.c_ru_bls_p,
    .blsC => localizations.c_ru_bls_c,
    .sbb => localizations.c_ru_sbb,
    .sbbP => localizations.c_ru_sbb_p,
    .sbbC => localizations.c_ru_sbb_c,
    .sbbCInt => localizations.c_ru_sbbc_int,
    .sbbD => localizations.c_ru_sbb_d,
    .sbbInfraBuildLog => localizations.c_ru_sbb_infra_baulog,
    .sbbInfra => localizations.c_ru_sbb_infra,
    .sobT => localizations.c_ru_sob_t,
    .sobInfra => localizations.c_ru_sob_infra,
    .thu => localizations.c_ru_thu,
    .ra => localizations.c_ru_ra,
    .travys => localizations.c_ru_travys,
    .transN => localizations.c_ru_transn,
    .tpfInfra => localizations.c_ru_tpf_infra,
    .tpfTrafic => localizations.c_ru_tpf_trafic,
    .tmr => localizations.c_ru_tmr,
    .mbc => localizations.c_ru_mbc,
    .unknown => localizations.c_unknown,
  };
}
