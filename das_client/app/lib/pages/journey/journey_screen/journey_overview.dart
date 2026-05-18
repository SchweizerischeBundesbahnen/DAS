import 'package:app/di/di.dart';
import 'package:app/i18n/src/build_context_x.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/pages/journey/brake_load_slip/brake_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/header.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/chronograph_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/connectivity_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/departure_authorization_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/short_term_change_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/suspicious_segment_view_model.dart';
import 'package:app/pages/journey/journey_screen/notification/notification_space.dart';
import 'package:app/pages/journey/journey_screen/view_model/advised_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/calculated_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/checklist_departure_process_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/departure_dispatch_notification_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/departure_process_warning_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/line_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/punctuality_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/replacement_series_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/tour_system_link_visibility_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/floating_departure_checklist_button.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_navigation_buttons.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_table.dart';
import 'package:app/pages/journey/view_model/decisive_gradient_view_model.dart';
import 'package:app/pages/journey/view_model/disturbance_view_model.dart';
import 'package:app/pages/journey/view_model/reauthentication_required_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyOverview extends StatelessWidget {
  static const double horizontalPadding = SBBSpacing.xSmall;

  const JourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return _ProviderScope(
      builder: (context) {
        final detailModalController = context.read<DetailModalViewModel>().controller;
        return Listener(
          onPointerDown: (_) => detailModalController.resetAutomaticClose(),
          onPointerUp: (_) => detailModalController.resetAutomaticClose(),
          child: Row(
            children: [
              Expanded(child: _content(context)),
              DetailModalSheet(),
            ],
          ),
        );
      },
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      children: [
        Header(),
        NotificationSpace(),
        Expanded(
          child: Stack(
            children: [
              JourneyTable(),
              Align(alignment: .bottomCenter, child: JourneyNavigationButtons()),
              Align(alignment: .bottomLeft, child: FloatingDepartureChecklistButton()),
              Align(alignment: .bottomCenter, child: _tourSystemLink(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tourSystemLink(BuildContext context) {
    final vm = context.read<TourSystemLinkVisibilityViewModel>();
    return StreamBuilder(
      stream: vm.model,
      initialData: vm.modelValue,
      builder: (context, asyncSnapshot) {
        final launcher = DI.get<Launcher>();
        if (asyncSnapshot.data != true || !launcher.hasTourSystemConfigured()) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: SBBSpacing.xLarge),
          decoration: ShapeDecoration(
            shape: StadiumBorder(
              side: BorderSide(color: ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.iron), width: 4.0),
            ),
          ),
          child: SBBTertiaryButton(
            labelText: context.l10n.p_journey_overview_tour_button_text,
            onPressed: () => launcher.launchTourSystem(),
          ),
        );
      },
    );
  }
}

class _ProviderScope extends StatelessWidget {
  const _ProviderScope({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<PunctualityViewModel>(
          create: (_) => DI.get<PunctualityViewModel>(),
        ),
        Provider<JourneyPositionViewModel>(
          create: (_) => DI.get<JourneyPositionViewModel>(),
        ),
        Provider<DepartureProcessWarningViewModel>(
          create: (_) => DI.get<DepartureProcessWarningViewModel>(),
        ),
        Provider<NotificationPriorityQueueViewModel>(
          create: (_) => DI.get<NotificationPriorityQueueViewModel>(),
        ),
        Provider<AdditionalSpeedRestrictionModalViewModel>(
          create: (_) => AdditionalSpeedRestrictionModalViewModel(),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<ArrivalDepartureTimeViewModel>(
          create: (_) => ArrivalDepartureTimeViewModel(journeyViewModel: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<DecisiveGradientViewModel>(
          create: (_) => DI.get(),
        ),
        Provider<UxTestingViewModel>(
          create: (_) => DI.get(),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<ConnectivityViewModel>(
          create: (_) => ConnectivityViewModel(connectivityManager: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<DetailModalViewModel>(
          create: (_) => DI.get<DetailModalViewModel>(),
        ),
        Provider<DisturbanceViewModel>(
          create: (_) => DI.get<DisturbanceViewModel>(),
        ),
        Provider<ChecklistDepartureProcessViewModel>(
          create: (_) => DI.get<ChecklistDepartureProcessViewModel>(),
        ),
        Provider<CollapsibleRowsViewModel>(
          create: (_) => DI.get<CollapsibleRowsViewModel>(),
        ),
        Provider<ReplacementSeriesViewModel>(
          create: (_) => DI.get<ReplacementSeriesViewModel>(),
        ),
        Provider<DepartureDispatchNotificationViewModel>(
          create: (_) => DI.get<DepartureDispatchNotificationViewModel>(),
        ),
        Provider<ShortTermChangeViewModel>(
          create: (_) => DI.get<ShortTermChangeViewModel>(),
        ),
        Provider<SuspiciousSegmentViewModel>(
          create: (_) => DI.get<SuspiciousSegmentViewModel>(),
        ),
        Provider<LineSpeedViewModel>(
          create: (_) => DI.get<LineSpeedViewModel>(),
        ),
        Provider<CalculatedSpeedViewModel>(
          create: (_) => DI.get<CalculatedSpeedViewModel>(),
        ),
        Provider<AdvisedSpeedViewModel>(
          create: (_) => DI.get<AdvisedSpeedViewModel>(),
        ),
        Provider<ChronographViewModel>(
          create: (_) => DI.get<ChronographViewModel>(),
        ),
        Provider<BrakeLoadSlipViewModel>(
          create: (_) => DI.get<BrakeLoadSlipViewModel>(),
        ),
        Provider<ReauthenticationRequiredViewModel>(
          create: (_) => ReauthenticationRequiredViewModel(
            authenticator: DI.get(),
            connectivityManager: DI.get(),
            notificationViewModel: DI.get(),
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<ServicePointModalViewModel>(
          create: (_) => ServicePointModalViewModel(
            localRegulationHtmlGenerator: DI.get(),
            settingsVM: DI.get(),
            journeyViewModel: DI.get(),
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<DepartureAuthorizationViewModel>(
          create: (_) => DepartureAuthorizationViewModel(
            journeyPositionStream: DI.get<JourneyPositionViewModel>().model,
            journeyViewModel: DI.get(),
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<TourSystemLinkVisibilityViewModel>(
          create: (_) => TourSystemLinkVisibilityViewModel(
            journeySettingsViewModel: DI.get(),
            journeyPositionViewModel: DI.get(),
            journeyViewModel: DI.get(),
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<JourneyTableViewModel>(
          create: (_) => DI.get(),
        ),
        Provider<JourneyTableAdvancementViewModel>(
          create: (_) => DI.get(),
        ),
      ],
      child: Builder(builder: builder),
    );
  }
}
