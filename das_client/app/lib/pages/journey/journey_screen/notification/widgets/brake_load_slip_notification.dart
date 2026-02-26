import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrakeLoadSlipNotification extends StatelessWidget {
  static const Key brakeLoadSlipNotificationKey = Key('brakeLoadSlipNotification');

  const BrakeLoadSlipNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BrakeLoadSlipViewModel>();

    return StreamBuilder(
      initialData: viewModel.formationChangedValue,
      stream: viewModel.formationChanged,
      builder: (context, snapshot) {
        final isFormationChanged = snapshot.data ?? false;
        if (!isFormationChanged) return SizedBox.shrink();

        return Container(
          key: brakeLoadSlipNotificationKey,
          child: SBBNotificationBox.information(
            text: context.l10n.w_brake_load_slip_notification_text,
            onTap: () => viewModel.open(context),
            isCloseable: false,
          ),
        );
      },
    );
  }
}
