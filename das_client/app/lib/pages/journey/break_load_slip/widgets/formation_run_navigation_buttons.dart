import 'package:app/pages/journey/break_load_slip/break_load_slip_view_model.dart';
import 'package:app/widgets/navigation_buttons.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class FormationRunNavigationButtons extends StatelessWidget {
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
        final selectedFormationRun = snap[1] as FormationRunChange;

        if (formation.formationRuns.length <= 1) return SizedBox.shrink();

        return NavigationButtons(
          currentPage: formation.formationRuns.indexOf(selectedFormationRun.formationRun),
          numberPages: formation.formationRuns.length,
          onPreviousPressed: () => viewModel.previous(),
          onNextPressed: () => viewModel.next(),
        );
      },
    );
  }
}
