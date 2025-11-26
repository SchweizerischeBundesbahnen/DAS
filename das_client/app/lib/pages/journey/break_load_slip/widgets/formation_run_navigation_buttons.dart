import 'package:app/pages/journey/break_load_slip/break_load_slip_view_model.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class FormationRunNavigationButtons extends StatelessWidget {
  static const Key formationRunNavigationButtonKey = Key('FormationRunNavigationButton');
  static const Key formationRunNavigationButtonPreviousKey = Key('FormationRunNavigationButtonPrevious');
  static const Key formationRunNavigationButtonNextKey = Key('FormationRunNavigationButtonNext');

  const FormationRunNavigationButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<BreakLoadSlipViewModel>();
    return StreamBuilder(
      stream: CombineLatestStream.list([viewModel.formation, viewModel.formationRun]),
      initialData: [viewModel.formationValue, viewModel.formationRunValue],
      builder: (context, snapshot) {
        final snap = snapshot.data;
        if (snap == null || snap[0] == null || snap[1] == null) return SizedBox.shrink();

        final formation = snap[0] as Formation;
        final selecteFormationRun = snap[1] as FormationRun;

        if (formation.formationRuns.length <= 1) return SizedBox.shrink();

        return Container(
          key: formationRunNavigationButtonKey,
          margin: EdgeInsets.only(bottom: sbbDefaultSpacing * 2),
          padding: EdgeInsets.all(sbbDefaultSpacing / 2),
          decoration: _navigationButtonsDecoration(context),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SBBIconButtonLarge(
                key: formationRunNavigationButtonPreviousKey,
                icon: SBBIcons.chevron_left_small,
                onPressed: () => viewModel.previous(),
              ),
              SizedBox(width: sbbDefaultSpacing),
              SBBPagination(
                numberPages: formation.formationRuns.length,
                currentPage: formation.formationRuns.indexOf(selecteFormationRun),
              ),
              SizedBox(width: sbbDefaultSpacing),
              SBBIconButtonLarge(
                key: formationRunNavigationButtonNextKey,
                icon: SBBIcons.chevron_right_small,
                onPressed: () => viewModel.next(),
              ),
            ],
          ),
        );
      },
    );
  }

  ShapeDecoration _navigationButtonsDecoration(BuildContext context) {
    final isDark = Theme.brightnessOf(context) == Brightness.dark;
    return ShapeDecoration(
      shape: StadiumBorder(),
      color: isDark ? SBBColors.granite : SBBColors.milk,
      shadows: [
        BoxShadow(
          blurRadius: sbbDefaultSpacing / 2,
          color: isDark ? SBBColors.white.withValues(alpha: .4) : SBBColors.black.withValues(alpha: .2),
        ),
      ],
    );
  }
}
