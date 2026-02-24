import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/util/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BrakeLoadSlipReplaceBrakeSeriesButton extends StatelessWidget {
  const BrakeLoadSlipReplaceBrakeSeriesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BrakeLoadSlipViewModel>();

    return StreamBuilder(
      stream: viewModel.settings,
      builder: (context, asyncSnapshot) {
        Widget child = SizedBox.shrink();

        // TODO: change to SBBSecondaryButton with custom label once v5.0.0 is released
        // TODO: https://github.com/SchweizerischeBundesbahnen/design_system_flutter/pull/425
        if (viewModel.isActiveFormationRun) {
          child = OutlinedButton(
            onPressed: viewModel.canApplyActiveFormationRunBrakeSeriesToJourney()
                ? () => viewModel.updateJourneyBrakeSeriesFromActiveFormationRun()
                : null,
            child: Text(context.l10n.p_brake_load_slip_button_apply_train_series),
          );
        }

        return AnimatedSwitcher(duration: DASAnimation.mediumDuration, child: child);
      },
    );
  }
}
