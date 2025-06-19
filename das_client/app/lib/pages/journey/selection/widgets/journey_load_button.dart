import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyLoadButton extends StatelessWidget {
  const JourneyLoadButton({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final model = snapshot.data;
        if (model == null) return SBBLoadingIndicator();

        return switch (model) {
          final Loading _ || final Loaded _ || Error _ => SizedBox.shrink(),
          final Selecting s => Padding(
            padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing / 2),
            child: SBBPrimaryButton(
              label: context.l10n.c_load_journey_button,
              onPressed: s.isInputComplete ? () => viewModel.loadTrainJourney() : null,
            ),
          ),
        };
      },
    );
  }
}
