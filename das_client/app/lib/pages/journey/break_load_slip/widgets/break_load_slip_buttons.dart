import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/view_model/break_load_slip_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipButtons extends StatelessWidget {
  const BreakLoadSlipButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BreakLoadSlipViewModel>();

    return StreamBuilder(
      stream: viewModel.settings,
      builder: (context, asyncSnapshot) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: sbbDefaultSpacing * 0.5,
          children: [
            if (viewModel.isActiveFormationRun)
              SBBSecondaryButton(
                label: context.l10n.p_break_load_slip_button_apply_train_series,
                onPressed: viewModel.isJourneyAndActiveFormationRunBreakSeriesDifferent()
                    ? () => viewModel.updateJourneyBreakSeriesFromActiveFormationRun()
                    : null,
              ),
            SBBTertiaryButtonLarge(
              label: context.l10n.p_break_load_slip_button_transport_documents,
              icon: SBBIcons.link_external_small,
              onPressed: () {},
            ),
          ],
        );
      },
    );
  }
}
