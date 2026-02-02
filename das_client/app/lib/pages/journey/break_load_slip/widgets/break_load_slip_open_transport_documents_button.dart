import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipOpenTransportDocumentsButton extends StatelessWidget {
  const BreakLoadSlipOpenTransportDocumentsButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBTertiaryButtonLarge(
      label: context.l10n.p_break_load_slip_button_transport_documents,
      icon: SBBIcons.link_external_small,
      onPressed: () {},
    );
  }
}
