import 'package:app/i18n/src/build_context_x.dart';
import 'package:flutter/material.dart';

enum TourSystem { tip, caros, railOpt, blsIvu, railCube }

extension TourSystemX on TourSystem {
  String localizedName(BuildContext context) => switch (this) {
    .tip => context.l10n.c_tour_system_tip,
    .caros => context.l10n.c_tour_system_caros,
    .railOpt => context.l10n.c_tour_system_rail_opt,
    .blsIvu => context.l10n.c_tour_system_bls_ivu,
    .railCube => context.l10n.c_tour_system_rail_cube,
  };
}
