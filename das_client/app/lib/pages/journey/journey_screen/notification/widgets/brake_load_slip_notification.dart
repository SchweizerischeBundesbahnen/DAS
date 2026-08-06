import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_screen/notification/widgets/animated_notification.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrakeLoadSlipNotification extends StatelessWidget {
  static const Key brakeLoadSlipNotificationKey = Key('brakeLoadSlipNotification');

  const BrakeLoadSlipNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BrakeLoadSlipViewModel>();

    return AnimatedNotification<bool>(
      initialData: viewModel.formationChangedValue,
      stream: viewModel.formationChanged,
      isVisible: (isFormationChanged) => isFormationChanged ?? false,
      builder: (context, _) => SBBNotificationBox.information(
        key: brakeLoadSlipNotificationKey,
        contentText: context.l10n.w_brake_load_slip_notification_text,
        onTap: () => viewModel.open(context),
        isDismissable: false,
      ),
    );
  }
}
