import 'package:app/i18n/src/build_context_x.dart';
import 'package:flutter/material.dart';

enum TourSystem {
  tip('https://www.dummy.com/'),
  caros('https://www.dummy.com/'),
  railOpt('https://www.dummy.com/'),
  blsIvu('https://www.dummy.com/'),
  railCube('https://www.dummy.com/'),
  ;

  const TourSystem(this.url);

  final String url;
}

extension TourSystemX on TourSystem {
  String localizedName(BuildContext context) {
    switch (this) {
      case TourSystem.tip:
        return context.l10n.c_tour_system_tip;
      case TourSystem.caros:
        return context.l10n.c_tour_system_caros;
      case TourSystem.railOpt:
        return context.l10n.c_tour_system_rail_opt;
      case TourSystem.blsIvu:
        return context.l10n.c_tour_system_bls_ivu;
      case TourSystem.railCube:
        return context.l10n.c_tour_system_rail_cube;
    }
  }
}
