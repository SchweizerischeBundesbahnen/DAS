import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/header_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrakeSlipButton extends StatelessWidget {
  const BrakeSlipButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<DetailModalViewModel>();
    final brakeLoadSlipVM = context.read<BrakeLoadSlipViewModel>();
    return StreamBuilder(
      initialData: brakeLoadSlipVM.formationValue,
      stream: brakeLoadSlipVM.formation,
      builder: (context, snapshot) {
        if (snapshot.data == null) return SizedBox.shrink();

        return StreamBuilder(
          initialData: viewModel.openModalTypeValue,
          stream: viewModel.openModalType,
          builder: (context, snapshot) {
            final openModalType = snapshot.data;
            return HeaderIconButton(
              label: context.l10n.p_journey_header_button_brake_slip,
              icon: SBBIcons.freight_wagon_container_medium,
              onPressed: openModalType != DetailModalType.brakeSlip ? () => brakeLoadSlipVM.open(context) : null,
            );
          },
        );
      },
    );
  }
}
