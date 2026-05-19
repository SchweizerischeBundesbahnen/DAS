import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/anchored_full_page_overlay.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_train_number_input.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneySearchOverlay extends StatelessWidget {
  static const Key journeySearchWidgetKey = Key('journeySearchWidget');
  static const Key journeySearchCloseKey = Key('closeJourneySearchButton');

  const JourneySearchOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<JourneySelectionViewModel>();
    return AnchoredFullPageOverlay(
      targetAnchor: .bottomLeft,
      followerAnchor: .topLeft,
      triggerBuilder: (_, showOverlay) => InkWell(
        key: journeySearchWidgetKey,
        borderRadius: BorderRadius.circular(SBBSpacing.xSmall),
        child: child,
        onTap: () {
          viewModel.dismissSelection();
          showOverlay();
        },
      ),
      contentBuilder: (_, hideOverlay) => Provider(
        create: (_) => DI.get<JourneySelectionViewModel>(),
        child: Builder(
          builder: (context) {
            return Column(
              mainAxisAlignment: .start,
              spacing: SBBSpacing.medium,
              children: [
                _header(context, hideOverlay),
                _inputFields(context),
                _loadJourneyButton(context, hideOverlay),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _inputFields(BuildContext context) {
    final vm = context.read<JourneySelectionViewModel>();

    return SBBContentBox(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          JourneyDateInput(isModalVersion: true),
          StreamBuilder(
            stream: vm.model,
            initialData: vm.modelValue,
            builder: (context, snapshot) {
              final model = snapshot.requireData;
              return SelectRailwayUndertakingInput(
                isModalVersion: true,
                selectedRailwayUndertakings: [model.railwayUndertaking],
                updateRailwayUndertaking: vm.updateRailwayUndertaking,
              );
            },
          ),
          JourneyTrainNumberInput(isModalVersion: true),
        ],
      ),
    );
  }

  Widget _header(BuildContext context, VoidCallback hideOverlay) {
    final viewModel = context.read<JourneySelectionViewModel>();
    return Row(
      crossAxisAlignment: .center,
      children: [
        Expanded(
          child: Text(
            context.l10n.w_journey_search_overlay_title,
            style: sbbTextStyle.lightStyle.large,
          ),
        ),
        StreamBuilder(
          stream: viewModel.model,
          builder: (context, snapshot) {
            final isLoading = snapshot.data is Loading;
            return SBBTertiaryButtonSmall(
              key: JourneySearchOverlay.journeySearchCloseKey,
              onPressed: isLoading ? null : () => hideOverlay(),
              iconData: SBBIcons.cross_small,
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

        final buttonLabel = context.l10n.c_button_confirm;
        return switch (model) {
          final Loading _ => SBBPrimaryButton(labelText: buttonLabel, onPressed: null, isLoading: true),
          final Selecting s => SBBPrimaryButton(
            labelText: buttonLabel,
            onPressed: s.isInputComplete
                ? () async {
                    hideOverlay();
                    await viewModel.loadJourney();
                  }
                : null,
          ),
          _ => SBBPrimaryButton(labelText: buttonLabel, onPressed: null),
        };
      },
    );
  }
}
