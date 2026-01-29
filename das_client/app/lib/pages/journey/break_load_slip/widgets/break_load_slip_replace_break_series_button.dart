import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_view_model.dart';
import 'package:app/util/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BreakLoadSlipReplaceBreakSeriesButton extends StatelessWidget {
  const BreakLoadSlipReplaceBreakSeriesButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BreakLoadSlipViewModel>();

    return StreamBuilder(
      stream: viewModel.settings,
      builder: (context, asyncSnapshot) {
        Widget child = SizedBox.shrink();

        // TODO: change to SBBSecondaryButton with custom style once v5.0.0 is released
        // TODO: https://github.com/SchweizerischeBundesbahnen/design_system_flutter/pull/425
        if (viewModel.isActiveFormationRun) {
          child = OutlinedButton(
            onPressed: viewModel.isJourneyAndActiveFormationRunBreakSeriesDifferent()
                ? () => viewModel.updateJourneyBreakSeriesFromActiveFormationRun()
                : null,
            style: ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(0.0, SBBSpacing.xLarge)),
              fixedSize: WidgetStatePropertyAll(Size.infinite),
            ),
            child: Text(context.l10n.p_break_load_slip_button_apply_train_series),
          );
        }

        return AnimatedSwitcher(duration: DASAnimation.mediumDuration, child: child);
      },
    );
  }
}
