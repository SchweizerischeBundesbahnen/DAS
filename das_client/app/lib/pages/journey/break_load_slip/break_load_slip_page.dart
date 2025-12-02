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
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class BreakLoadSlipPage extends StatelessWidget implements AutoRouteWrapper {
  const BreakLoadSlipPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => MultiProvider(
    providers: [
      Provider<JourneyTableViewModel>(create: (_) => DI.get()),

      // PROXY  PROVIDERS
      ProxyProvider<JourneyTableViewModel, PunctualityViewModel>(
        update: (_, journeyVM, prev) {
          if (prev != null) return prev;
          return PunctualityViewModel(
            journeyStream: journeyVM.journey,
          );
        },
        dispose: (_, vm) => vm.dispose(),
      ),
      ProxyProvider2<JourneyTableViewModel, PunctualityViewModel, JourneyPositionViewModel>(
        update: (_, journeyVM, punctualityVM, prev) {
          if (prev != null) return prev;
          return JourneyPositionViewModel(
            journeyStream: journeyVM.journey,
            punctualityStream: punctualityVM.model,
          );
        },
        dispose: (_, vm) => vm.dispose(),
      ),
      ProxyProvider2<JourneyTableViewModel, JourneyPositionViewModel, BreakLoadSlipViewModel>(
        update: (_, journeyVM, positionVM, prev) {
          if (prev != null) return prev;
          return BreakLoadSlipViewModel(
            journeyTableViewModel: journeyVM,
            journeyPositionViewModel: positionVM,
            formationRepository: DI.get(),
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
        final formationRun = snap[1] as FormationRun;

        return Stack(
          children: [
            Column(
              spacing: sbbDefaultSpacing,
              children: [
                BreakLoadSlipHeader(formationRun: formationRun),
                SingleChildScrollView(
                  child: Column(
                    spacing: sbbDefaultSpacing,
                    children: [
                      BreakLoadSlipTrainDetails(formation: formation, formationRun: formationRun),
                      _secondRow(context, formation, formationRun),
                    ],
                  ),
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

  Row _specialRestrctionsAndBrakeDetailsRow(BuildContext context, Formation formation, FormationRun formationRun) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: sbbDefaultSpacing,
      children: [
        Expanded(
          child: BreakLoadSlipSpecialRestrictions(formationRun: formationRun),
        ),
        Expanded(
          child: BreakLoadSlipBrakeDetails(formationRun: formationRun),
        ),
      ],
    );
  }

  Widget _secondRow(BuildContext context, Formation formation, FormationRun formationRun) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: sbbDefaultSpacing,
        children: [
          Expanded(
            flex: 1,
            child: BreakLoadSlipHauledLoadDetails(formationRun: formationRun),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _specialRestrctionsAndBrakeDetailsRow(context, formation, formationRun),
                SizedBox(height: sbbDefaultSpacing),
                BreakLoadSlipButtons(formationRun: formationRun),
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
    icon: const Icon(SBBIcons.chevron_left_small),
    onPressed: () {
      if (context.mounted) {
        context.router.pop();
      }
    },
  );
}
