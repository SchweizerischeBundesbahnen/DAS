import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/selection/journey_selection_model.dart';
import 'package:app/pages/journey/selection/journey_selection_view_model.dart';
import 'package:app/pages/journey/selection/widgets/journey_date_input.dart';
import 'package:app/pages/journey/selection/widgets/journey_train_number_input.dart';
import 'package:app/pages/journey/widgets/close_journey_dialog.dart';
import 'package:app/widgets/company_selection/widgets/select_company_input.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneySearchOverlay extends StatelessWidget {
  static const Key journeySearchWidgetKey = Key('journeySearchWidget');

  const JourneySearchOverlay({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final viewModel = DI.get<JourneySelectionViewModel>();
    return SBBPopover(
      placement: .bottomStart,
      targetBuilder: (_, showPopover) => InkWell(
        key: journeySearchWidgetKey,
        borderRadius: BorderRadius.circular(SBBSpacing.xSmall),
        child: child,
        onTap: () {
          viewModel.dismissSelection();
          showPopover();
        },
      ),
      titleText: context.l10n.w_journey_search_overlay_title,
      builder: (_, hidePopover) => Provider(
        create: (_) => DI.get<JourneySelectionViewModel>(),
        child: Builder(
          builder: (context) {
            return Column(
              mainAxisSize: .min,
              mainAxisAlignment: .start,
              spacing: SBBSpacing.medium,
              children: [
                _inputFields(context),
                _loadJourneyButton(context, hidePopover),
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
          JourneyTrainNumberInput(isModalVersion: true),
          StreamBuilder(
            stream: vm.model,
            initialData: vm.modelValue,
            builder: (context, snapshot) {
              final model = snapshot.requireData;
              return SelectCompanyInput(
                isModalVersion: true,
                selectedCompanyCodes: [?model.companyCode],
                updateCompanies: vm.updateCompanies,
                addClearButton: true,
              );
            },
          ),
        ],
      ),
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
                    if (viewModel.willReplaceLoadedJourney && !await confirmCloseJourney(context)) return;
                    if (!context.mounted) return;

                    final success = await viewModel.loadJourney();
                    if (!success && context.mounted) {
                      context.router.replace(JourneySelectionRoute());
                    }
                    hideOverlay();
                  }
                : null,
          ),
          _ => SBBPrimaryButton(labelText: buttonLabel, onPressed: null),
        };
      },
    );
  }
}
