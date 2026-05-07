import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/util/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrakeLoadSlipReplaceBrakeSeriesButton extends StatelessWidget {
  const BrakeLoadSlipReplaceBrakeSeriesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BrakeLoadSlipViewModel>();

    return StreamBuilder(
      stream: viewModel.settings,
      builder: (context, asyncSnapshot) {
        Widget child = SizedBox.shrink();

        if (viewModel.isActiveFormationRun) {
          child = SBBSecondaryButton(
            onPressed: viewModel.canApplyActiveFormationRunBrakeSeriesToJourney()
                ? () => viewModel.updateJourneyBrakeSeriesFromActiveFormationRun()
                : null,
            label: Text(context.l10n.p_brake_load_slip_button_apply_train_series), // TODO: Why is this needed?
          );
        }

        return AnimatedSwitcher(duration: DASAnimation.mediumDuration, child: child);
      },
    );
  }
}
