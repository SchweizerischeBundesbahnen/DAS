import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/journey_screen/widgets/anchored_full_page_overlay.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_train_number_input.dart';
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
      triggerBuilder: (_, showOverlay) {
        return InkWell(
          key: journeySearchWidgetKey,
          borderRadius: BorderRadius.circular(SBBSpacing.xSmall),
          child: child,
          onTap: () {
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
                mainAxisAlignment: .start,
                children: [
                  _header(context, hideOverlay),
                  SizedBox(height: SBBSpacing.medium),
                  SBBContentBox(child: _inputFields()),
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
      crossAxisAlignment: .start,
      children: [
        JourneyDateInput(isModalVersion: true),
        SelectRailwayUndertakingInput(isModalVersion: true),
        JourneyTrainNumberInput(isModalVersion: true),
      ],
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
          padding: const .symmetric(vertical: SBBSpacing.medium, horizontal: SBBSpacing.xSmall),
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
                      viewModel.loadJourney();
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
