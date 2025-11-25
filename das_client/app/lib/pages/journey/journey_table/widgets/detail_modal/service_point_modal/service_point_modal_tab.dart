import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/das_icons.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

enum ServicePointModalTab {
  communication(icon: SBBIcons.telephone_gsm_small),
  graduatedSpeeds(icon: DasIcons.appIconSmallTempo),
  localRegulations(icon: SBBIcons.location_pin_surrounding_area_small)
  ;

  const ServicePointModalTab({required this.icon});

  String localized(BuildContext context) {
    switch (this) {
      case communication:
        return context.l10n.w_service_point_modal_communication_label;
      case graduatedSpeeds:
        return context.l10n.w_service_point_modal_graduated_speed_label;
      case localRegulations:
        return context.l10n.w_service_point_modal_local_regulations_label;
    }
  }

  final IconData icon;
}
