import 'package:das_client/app/i18n/i18n.dart';
import 'package:flutter/material.dart';

enum Evu {
  sbbP(companyCode: '1085'),
  sbbC(companyCode: '2185'),
  blsP(companyCode: '1163'),
  blsC(companyCode: '3356'),
  sob(companyCode: '5458');

  const Evu({
    required this.companyCode,
  });

  final String companyCode;
}

extension EvuExtension on Evu {
  String displayText(BuildContext context) {
    switch (this) {
      case Evu.sbbP:
        return context.l10n.c_evu_sbb_p;
      case Evu.sbbC:
        return context.l10n.c_evu_sbb_c;
      case Evu.blsP:
        return context.l10n.c_evu_bls_p;
      case Evu.blsC:
        return context.l10n.c_evu_bls_c;
      case Evu.sob:
        return context.l10n.c_evu_sob;
    }
  }
}
