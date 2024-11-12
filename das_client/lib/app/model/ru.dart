import 'package:das_client/app/i18n/i18n.dart';
import 'package:flutter/material.dart';

enum Ru {
  sbbP(companyCode: '1085'),
  sbbC(companyCode: '2185'),
  blsP(companyCode: '1163'),
  blsC(companyCode: '3356'),
  sob(companyCode: '5458');

  const Ru({
    required this.companyCode,
  });

  final String companyCode;
}

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
