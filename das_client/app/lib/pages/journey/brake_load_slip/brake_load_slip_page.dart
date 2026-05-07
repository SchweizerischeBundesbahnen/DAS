import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_brake_details.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_hauled_load_details.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_header_box.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_open_transport_documents_button.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_special_restrictions.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/brake_load_slip_train_details.dart';
import 'package:app/pages/journey/brake_load_slip/widgets/formation_run_navigation_buttons.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/punctuality_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:formation/component.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class BrakeLoadSlipPage extends StatelessWidget implements AutoRouteWrapper {
  const BrakeLoadSlipPage({super.key});

  static const Key dismissButtonKey = Key('dismissBrakeLoadSlipPageButton');

  @override
  Widget wrappedRoute(BuildContext context) => MultiProvider(
    providers: [
      Provider<JourneyViewModel>(create: (_) => DI.get<JourneyViewModel>()),
      Provider<JourneySettingsViewModel>(create: (_) => DI.get<JourneySettingsViewModel>()),
      Provider<PunctualityViewModel>(create: (_) => DI.get<PunctualityViewModel>()),
      Provider<JourneyPositionViewModel>(create: (_) => DI.get<JourneyPositionViewModel>()),
      ProxyProvider3<JourneyViewModel, JourneyPositionViewModel, JourneySettingsViewModel, BrakeLoadSlipViewModel>(
        update: (_, journeyVM, positionVM, settingsVM, prev) {
          if (prev != null) return prev;
          return BrakeLoadSlipViewModel(
            journeyViewModel: journeyVM,
            journeyPositionViewModel: positionVM,
            notificationViewModel: DI.get(),
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
    return SBBHeaderSmall(
      titleText: context.l10n.p_brake_load_slip_page_title,
      leading: _DismissButton(),
      actions: [], // removes SBB logo
    );
  }

  Widget _body(BuildContext context) {
    final viewModel = context.read<BrakeLoadSlipViewModel>();

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
              spacing: SBBSpacing.medium,
              crossAxisAlignment: .start,
              children: [
                BrakeLoadSlipHeaderBox(formationRunChange: formationRunChange),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.medium),
                    child: _content(formation, formationRunChange),
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

  Widget _content(Formation formation, FormationRunChange formationRunChange) {
    return Row(
      crossAxisAlignment: .start,
      spacing: SBBSpacing.medium,
      children: [
        Expanded(
          child: Column(
            mainAxisSize: .min,
            spacing: SBBSpacing.xSmall,
            crossAxisAlignment: .start,
            children: [
              BrakeLoadSlipTrainDetails(
                formation: formation,
                formationRunChange: formationRunChange,
              ),
              BrakeLoadSlipOpenTransportDocumentsButton(),
            ],
          ),
        ),
        Expanded(child: _loadDetailsColumn(formationRunChange)),
      ],
    );
  }

  Widget _noDataAvailable(BuildContext context) {
    return Center(
      child: SBBMessage(
        illustration: SBBIllustration.display(),
        titleText: context.l10n.p_brake_load_slip_no_data_available,
      ),
    );
  }

  Widget _loadDetailsColumn(FormationRunChange formationRun) {
    return Column(
      spacing: SBBSpacing.medium,
      children: [
        BrakeLoadSlipBrakeDetails(formationRunChange: formationRun),
        BrakeLoadSlipSpecialRestrictions(formationRunChange: formationRun),
        BrakeLoadSlipHauledLoadDetails(formationRunChange: formationRun),
      ],
    );
  }
}

class _DismissButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => IconButton(
    key: BrakeLoadSlipPage.dismissButtonKey,
    icon: const Icon(SBBIcons.chevron_left_small),
    onPressed: () {
      if (context.mounted) {
        context.router.pop();
      }
    },
  );
}
