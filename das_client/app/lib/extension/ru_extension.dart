import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

extension RuExtension on RailwayUndertaking {
  String displayText(BuildContext context) => switch (this) {
    RailwayUndertaking.sbbP => context.l10n.c_ru_sbb_p,
    RailwayUndertaking.sbbC => context.l10n.c_ru_sbb_c,
    RailwayUndertaking.blsP => context.l10n.c_ru_bls_p,
    RailwayUndertaking.blsC => context.l10n.c_ru_bls_c,
    RailwayUndertaking.sob => context.l10n.c_ru_sob,
    RailwayUndertaking.unknown => context.l10n.c_unknown,
  };

  String localizedText(AppLocalizations localizations) => switch (this) {
    RailwayUndertaking.sbbP => localizations.c_ru_sbb_p,
    RailwayUndertaking.sbbC => localizations.c_ru_sbb_c,
    RailwayUndertaking.blsP => localizations.c_ru_bls_p,
    RailwayUndertaking.blsC => localizations.c_ru_bls_c,
    RailwayUndertaking.sob => localizations.c_ru_sob,
    RailwayUndertaking.unknown => localizations.c_unknown,
  };
}
