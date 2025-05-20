import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

extension RuExtension on RailwayUndertaking {
  String displayText(BuildContext context) {
    switch (this) {
      case RailwayUndertaking.sbbP:
        return context.l10n.c_ru_sbb_p;
      case RailwayUndertaking.sbbC:
        return context.l10n.c_ru_sbb_c;
      case RailwayUndertaking.blsP:
        return context.l10n.c_ru_bls_p;
      case RailwayUndertaking.blsC:
        return context.l10n.c_ru_bls_c;
      case RailwayUndertaking.sob:
        return context.l10n.c_ru_sob;
    }
  }
}
