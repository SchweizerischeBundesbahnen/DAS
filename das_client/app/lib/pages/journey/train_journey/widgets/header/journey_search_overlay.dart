import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/railway_undertaking/widgets/journey_railway_undertaking_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_train_number_input.dart';
import 'package:app/pages/journey/train_journey/widgets/anchored_full_page_overlay.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneySearchOverlay extends StatelessWidget {
  static const Key journeySearchKey = Key('journeySearchButton');
  static const Key journeySearchCloseKey = Key('closeJourneySearchButton');

  const JourneySearchOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<JourneySelectionViewModel>();
    return AnchoredFullPageOverlay(
      triggerBuilder: (_, showOverlay) {
        return SBBIconButtonLarge(
          key: JourneySearchOverlay.journeySearchKey,
          icon: SBBIcons.magnifying_glass_small,
          onPressed: () {
            viewModel.dismissSelection();
            showOverlay();
          },
        );
      },
      contentBuilder: (_, hideOverlay) {
        return Provider(
          create: (_) => DI.get<JourneySelectionViewModel>(),
          child: Builder(
            builder: (context) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _header(context, hideOverlay),
                  SizedBox(height: sbbDefaultSpacing),
                  SBBGroup(child: _inputFields()),
                  _loadJourneyButton(context, hideOverlay),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _inputFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        JourneyTrainNumberInput(isModalVersion: true),
        JourneyDateInput(isModalVersion: true),
        JourneyRailwayUndertakingInput(isModalVersion: true),
      ],
    );
  }

  Widget _header(BuildContext context, VoidCallback hideOverlay) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            context.l10n.w_journey_search_overlay_title,
            style: DASTextStyles.largeLight,
          ),
        ),
        StreamBuilder(
          stream: viewModel.model,
          builder: (context, snapshot) {
            final isLoading = snapshot.data is Loading;
            return SBBIconButtonSmall(
              key: JourneySearchOverlay.journeySearchCloseKey,
              onPressed: isLoading ? null : () => hideOverlay(),
              icon: SBBIcons.cross_small,
            );
          },
        ),
      ],
    );
  }

  Widget _loadJourneyButton(BuildContext context, VoidCallback hideOverlay) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return StreamBuilder(
      stream: viewModel.model,
      builder: (context, snapshot) {
        final model = snapshot.data;

        Widget wrapWithPadding(Widget child) => Padding(
          padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing * 0.5),
          child: child,
        );

        final buttonLabel = context.l10n.c_button_confirm;
        return switch (model) {
          final Loading _ => wrapWithPadding(SBBPrimaryButton(label: buttonLabel, onPressed: null, isLoading: true)),
          final Selecting s => wrapWithPadding(
            SBBPrimaryButton(
              label: buttonLabel,
              onPressed: s.isInputComplete
                  ? () {
                      hideOverlay();
                      viewModel.loadTrainJourney();
                    }
                  : null,
            ),
          ),
          _ => wrapWithPadding(SBBPrimaryButton(label: buttonLabel, onPressed: null)),
        };
      },
    );
  }
}
