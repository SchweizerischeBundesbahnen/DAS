import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_view_model.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_brake_details.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_buttons.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_hauled_load_details.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_header.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_special_restrictions.dart';
import 'package:app/pages/journey/break_load_slip/widgets/break_load_slip_train_details.dart';
import 'package:app/pages/journey/break_load_slip/widgets/formation_run_navigation_buttons.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/punctuality/punctuality_view_model.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/pages/journey/settings/journey_settings_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class BreakLoadSlipPage extends StatelessWidget implements AutoRouteWrapper {
  const BreakLoadSlipPage({super.key});

  static const Key dismissButtonKey = Key('dismissBreakLoadSlipPageButton');

  @override
  Widget wrappedRoute(BuildContext context) => MultiProvider(
    providers: [
      Provider<JourneyTableViewModel>(create: (_) => DI.get<JourneyTableViewModel>()),
      Provider<JourneySettingsViewModel>(create: (_) => DI.get<JourneySettingsViewModel>()),
      Provider<PunctualityViewModel>(create: (_) => DI.get<PunctualityViewModel>()),
      Provider<JourneyPositionViewModel>(create: (_) => DI.get<JourneyPositionViewModel>()),
      ProxyProvider3<JourneyTableViewModel, JourneyPositionViewModel, JourneySettingsViewModel, BreakLoadSlipViewModel>(
        update: (_, journeyVM, positionVM, settingsVM, prev) {
          if (prev != null) return prev;
          return BreakLoadSlipViewModel(
            journeyTableViewModel: journeyVM,
            journeyPositionViewModel: positionVM,
            formationRepository: DI.get(),
            journeySettingsViewModel: settingsVM,
          );
        },
        dispose: (_, vm) => vm.dispose(),
      ),
    ],
    child: this,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
    );
  }

  PreferredSizeWidget _appBar(BuildContext context) {
    return SBBHeader(
      title: context.l10n.p_break_load_slip_page_title,
      leadingWidget: _DismissButton(),
      // Removes SBB Icon in AppBar
      actions: [Container()],
    );
  }

  Widget _body(BuildContext context) {
    final viewModel = context.read<BreakLoadSlipViewModel>();

    return StreamBuilder(
      stream: CombineLatestStream.list([viewModel.formation, viewModel.formationRun]),
      initialData: [viewModel.formationValue, viewModel.formationRunValue],
      builder: (context, snapshot) {
        final snap = snapshot.data;
        if (snap == null || snap[0] == null || snap[1] == null) return _noDataAvailable(context);

        final formation = snap[0] as Formation;
        final formationRunChange = snap[1] as FormationRunChange;

        return Stack(
          children: [
            Column(
              spacing: sbbDefaultSpacing,
              children: [
                BreakLoadSlipHeader(formationRun: formationRunChange.formationRun),
                Column(
                  spacing: sbbDefaultSpacing,
                  children: [
                    BreakLoadSlipTrainDetails(formation: formation, formationRunChange: formationRunChange),
                    _loadDetailsAndButtons(context, formation, formationRunChange),
                  ],
                ),
              ],
            ),
            Align(alignment: Alignment.bottomCenter, child: FormationRunNavigationButtons()),
          ],
        );
      },
    );
  }

  Widget _noDataAvailable(BuildContext context) {
    return Center(
      child: SBBMessage(
        illustration: MessageIllustration.Display,
        title: context.l10n.p_break_load_slip_no_data_available,
        description: '',
      ),
    );
  }

  Row _specialRestrictionsAndBrakeDetailsRow(
    BuildContext context,
    Formation formation,
    FormationRunChange formationRun,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: sbbDefaultSpacing,
      children: [
        Expanded(
          child: BreakLoadSlipSpecialRestrictions(formationRunChange: formationRun),
        ),
        Expanded(
          child: BreakLoadSlipBrakeDetails(formationRunChange: formationRun),
        ),
      ],
    );
  }

  Widget _loadDetailsAndButtons(BuildContext context, Formation formation, FormationRunChange formationRun) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sbbDefaultSpacing,
        children: [
          Expanded(
            flex: 1,
            child: BreakLoadSlipHauledLoadDetails(formationRunChange: formationRun),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _specialRestrictionsAndBrakeDetailsRow(context, formation, formationRun),
                SizedBox(height: sbbDefaultSpacing),
                BreakLoadSlipButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DismissButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    key: BreakLoadSlipPage.dismissButtonKey,
    icon: const Icon(SBBIcons.chevron_left_small),
    onPressed: () {
      if (context.mounted) {
        context.router.pop();
      }
    },
  );
}
