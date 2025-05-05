import 'package:app/i18n/i18n.dart';
import 'package:sfera/src/model/ru.dart';
import 'package:flutter/material.dart';

extension RuExtension on Ru {
  String displayText(BuildContext context) {
    switch (this) {
      case Ru.sbbP:
        return context.l10n.c_ru_sbb_p;
      case Ru.sbbC:
        return context.l10n.c_ru_sbb_c;
      case Ru.blsP:
        return context.l10n.c_ru_bls_p;
      case Ru.blsC:
        return context.l10n.c_ru_bls_c;
      case Ru.sob:
        return context.l10n.c_ru_sob;
    }
  }
}
