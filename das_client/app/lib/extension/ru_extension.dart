import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

extension RuExtension on RailwayUndertaking {
  String displayText(BuildContext context) => switch (this) {
    RailwayUndertaking.blsN => context.l10n.c_ru_bls_n,
    RailwayUndertaking.blsP => context.l10n.c_ru_bls_p,
    RailwayUndertaking.blsNEvu => context.l10n.c_ru_bls_nevu,
    RailwayUndertaking.blsC => context.l10n.c_ru_bls_c,
    RailwayUndertaking.sbb => context.l10n.c_ru_sbb,
    RailwayUndertaking.sbbP => context.l10n.c_ru_sbb_p,
    RailwayUndertaking.sbbEPA => context.l10n.c_ru_sbb_epa,
    RailwayUndertaking.sbbC => context.l10n.c_ru_sbb_c,
    RailwayUndertaking.sbbCInt => context.l10n.c_ru_sbbc_int,
    RailwayUndertaking.sbbD => context.l10n.c_ru_sbb_d,
    RailwayUndertaking.sbbInfraBuildLog => context.l10n.c_ru_sbb_infra_baulog,
    RailwayUndertaking.sbbInfraPath => context.l10n.c_ru_sbb_infra_path,
    RailwayUndertaking.sobT => context.l10n.c_ru_sob_t,
    RailwayUndertaking.sobI => context.l10n.c_ru_sob_i,
    RailwayUndertaking.sobITi => context.l10n.c_ru_sob_iti,
    RailwayUndertaking.thu => context.l10n.c_ru_thu,
    RailwayUndertaking.ra => context.l10n.c_ru_ra,
    RailwayUndertaking.travys => context.l10n.c_ru_travys,
    RailwayUndertaking.transN => context.l10n.c_ru_transn,
    RailwayUndertaking.tpfInfra => context.l10n.c_ru_tpfinfra,
    RailwayUndertaking.tpfTrafic => context.l10n.c_ru_tpftrafic,
    RailwayUndertaking.tmr => context.l10n.c_ru_tmr,
    RailwayUndertaking.mbc => context.l10n.c_ru_mbc,
  };

  String localizedText(AppLocalizations localizations) => switch (this) {
    RailwayUndertaking.blsN => localizations.c_ru_bls_n,
    RailwayUndertaking.blsP => localizations.c_ru_bls_p,
    RailwayUndertaking.blsNEvu => localizations.c_ru_bls_nevu,
    RailwayUndertaking.blsC => localizations.c_ru_bls_c,
    RailwayUndertaking.sbb => localizations.c_ru_sbb,
    RailwayUndertaking.sbbP => localizations.c_ru_sbb_p,
    RailwayUndertaking.sbbEPA => localizations.c_ru_sbb_epa,
    RailwayUndertaking.sbbC => localizations.c_ru_sbb_c,
    RailwayUndertaking.sbbCInt => localizations.c_ru_sbbc_int,
    RailwayUndertaking.sbbD => localizations.c_ru_sbb_d,
    RailwayUndertaking.sbbInfraBuildLog => localizations.c_ru_sbb_infra_baulog,
    RailwayUndertaking.sbbInfraPath => localizations.c_ru_sbb_infra_path,
    RailwayUndertaking.sobT => localizations.c_ru_sob_t,
    RailwayUndertaking.sobI => localizations.c_ru_sob_i,
    RailwayUndertaking.sobITi => localizations.c_ru_sob_iti,
    RailwayUndertaking.thu => localizations.c_ru_thu,
    RailwayUndertaking.ra => localizations.c_ru_ra,
    RailwayUndertaking.travys => localizations.c_ru_travys,
    RailwayUndertaking.transN => localizations.c_ru_transn,
    RailwayUndertaking.tpfInfra => localizations.c_ru_tpfinfra,
    RailwayUndertaking.tpfTrafic => localizations.c_ru_tpftrafic,
    RailwayUndertaking.tmr => localizations.c_ru_tmr,
    RailwayUndertaking.mbc => localizations.c_ru_mbc,
  };
}
