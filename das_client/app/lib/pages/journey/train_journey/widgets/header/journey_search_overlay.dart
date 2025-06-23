import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_railway_undertaking_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_train_number_input.dart';
import 'package:app/pages/journey/train_journey/widgets/anchored_full_page_overlay.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:auto_route/auto_route.dart';
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
      triggerBuilder: (context, showOverlay) {
        return SBBIconButtonLarge(
          key: JourneySearchOverlay.journeySearchKey,
          icon: SBBIcons.magnifying_glass_small,
          onPressed: () {
            viewModel.dismissSelection();
            showOverlay();
          },
        );
      },
      contentBuilder: (context, hideOverlay) {
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            context.l10n.w_journey_search_overlay_title,
            style: DASTextStyles.largeLight,
          ),
        ),
        SBBIconButtonSmall(
          key: JourneySearchOverlay.journeySearchCloseKey,
          onPressed: () => hideOverlay(),
          icon: SBBIcons.cross_small,
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
        if (model == null) return SBBLoadingIndicator();

        return switch (model) {
          final Loading _ || final Loaded _ || Error _ => SizedBox.shrink(),
          final Selecting s => Padding(
            padding: const EdgeInsets.symmetric(vertical: sbbDefaultSpacing, horizontal: sbbDefaultSpacing / 2),
            child: SBBPrimaryButton(
              label: context.l10n.c_button_confirm,
              onPressed: s.isInputComplete
                  ? () {
                      hideOverlay();
                      viewModel.loadTrainJourney();
                      context.router.replace(JourneySelectionRoute());
                    }
                  : null,
            ),
          ),
        };
      },
    );
  }
}
