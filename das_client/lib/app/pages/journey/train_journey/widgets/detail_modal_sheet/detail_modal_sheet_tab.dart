import 'package:das_client/app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

enum DetailModalSheetTab {
  radioChannels(icon: SBBIcons.telephone_gsm_small),
  graduatedSpeeds(icon: SBBIcons.question_mark_small),
  localRegulations(icon: SBBIcons.location_pin_surrounding_area_small);

  const DetailModalSheetTab({required this.icon});

  String localized(BuildContext context) {
    switch (this) {
      case radioChannels:
        return context.l10n.w_detail_modal_sheet_radio_channel_label;
      case graduatedSpeeds:
        return context.l10n.w_detail_modal_sheet_graduated_speed_label;
      case localRegulations:
        return context.l10n.w_detail_modal_sheet_local_regulations_label;
    }
  }

  final IconData icon;
}
