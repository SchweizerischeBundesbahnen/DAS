import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/view_model/break_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_table/journey_overview.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipNotification extends StatelessWidget {
  static const Key breakLoadSlipNotificationKey = Key('breakLoadSlipNotification');

  const BreakLoadSlipNotification({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BreakLoadSlipViewModel>();

    return StreamBuilder(
      initialData: viewModel.formationChangedValue,
      stream: viewModel.formationChanged,
      builder: (context, snapshot) {
        final isFormationChanged = snapshot.data ?? false;
        if (!isFormationChanged) return SizedBox.shrink();

        return Container(
          key: breakLoadSlipNotificationKey,
          margin: const EdgeInsets.all(JourneyOverview.horizontalPadding).copyWith(top: 0),
          child: SBBNotificationBox.information(
            text: context.l10n.w_break_load_slip_notification_text,
            onTap: () => viewModel.open(context),
            isCloseable: false,
          ),
        );
      },
    );
  }
}
