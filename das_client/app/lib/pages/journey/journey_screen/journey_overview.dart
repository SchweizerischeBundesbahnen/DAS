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
import 'package:app/pages/journey/journey_screen/view_model/model/replacement_series_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/notification_priority_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/punctuality_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/replacement_series_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/tour_system_link_visibility_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/FloatingDepartureChecklistButton.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_navigation_buttons.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_table.dart';
import 'package:app/pages/journey/view_model/decisive_gradient_view_model.dart';
import 'package:app/pages/journey/view_model/disturbance_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_view_model.dart';
import 'package:app/provider/ru_feature_provider.dart';
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
            ],
          ),
        ),
        _tourSystemLink(context),
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

        return Padding(
          padding: const EdgeInsets.only(top: SBBSpacing.xSmall, bottom: SBBSpacing.large),
          child: SBBTertiaryButtonLarge(
            label: context.l10n.p_journey_overview_tour_button_text,
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
    final journeyViewModel = context.read<JourneyViewModel>();
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
        Provider<JourneyTableAdvancementViewModel>(
          create: (_) => DI.get<JourneyTableAdvancementViewModel>(),
        ),
        Provider<NotificationPriorityQueueViewModel>(
          create: (_) => DI.get<NotificationPriorityQueueViewModel>(),
        ),
        Provider<AdditionalSpeedRestrictionModalViewModel>(
          create: (_) => AdditionalSpeedRestrictionModalViewModel(),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<ArrivalDepartureTimeViewModel>(
          create: (_) => ArrivalDepartureTimeViewModel(),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<DecisiveGradientViewModel>(
          create: (_) => DecisiveGradientViewModel(),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<UxTestingViewModel>(
          lazy: false,
          create: (_) => UxTestingViewModel(
            sferaRepo: DI.get(),
            ruFeatureProvider: DI.get(),
            formationRepository: DI.get(),
            notificationViewModel: DI.get(),
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<ConnectivityViewModel>(
          create: (_) => ConnectivityViewModel(connectivityManager: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),

        // PROXY  PROVIDERS
        ProxyProvider<NotificationPriorityQueueViewModel, DisturbanceViewModel>(
          lazy: false,
          update: (_, notificationVM, prev) {
            if (prev != null) return prev;
            return DisturbanceViewModel(sferaRepo: DI.get(), notificationVM: notificationVM);
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider2<JourneyViewModel, JourneySettingsViewModel, ServicePointModalViewModel>(
          lazy: false,
          update: (_, journeyVM, settingsVM, prev) {
            if (prev != null) return prev;
            return ServicePointModalViewModel(
              localRegulationHtmlGenerator: DI.get(),
              settingsVM: settingsVM,
              journeyViewModel: journeyVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider<JourneyPositionViewModel, CollapsibleRowsViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return CollapsibleRowsViewModel(
              journeyPositionStream: journeyPositionVM.model,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),

        ProxyProvider<JourneyTableAdvancementViewModel, DetailModalViewModel>(
          update: (_, advancementVM, prev) {
            if (prev != null) return prev;
            return DetailModalViewModel(onDetailModalOpen: advancementVM.scrollToCurrentPositionIfNotPaused);
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider3<
          JourneyViewModel,
          JourneyPositionViewModel,
          UxTestingViewModel,
          ChecklistDepartureProcessViewModel
        >(
          update: (_, journeyVM, positionVM, uxTestingVM, prev) {
            if (prev != null) return prev;
            return ChecklistDepartureProcessViewModel(
              journeyViewModel: journeyVM,
              journeyPositionViewModel: positionVM,
              ruFeatureProvider: DI.get<RuFeatureProvider>(),
              uxTestingViewModel: uxTestingVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider3<
          JourneyPositionViewModel,
          JourneySettingsViewModel,
          NotificationPriorityQueueViewModel,
          ReplacementSeriesViewModel
        >(
          lazy: false,
          update: (_, journeyPositionVM, settingsVM, notificationVM, prev) {
            if (prev != null) return prev;
            final vm = ReplacementSeriesViewModel(
              journeyViewModel: journeyViewModel,
              journeyPositionViewModel: journeyPositionVM,
              journeySettingsViewModel: settingsVM,
            );
            notificationVM.addStream(
              type: .illegalSegmentNoReplacement,
              stream: vm.model.map((m) => m is NoReplacementSeries),
            );
            notificationVM.addStream(
              type: .illegalSegmentWithReplacement,
              stream: vm.model.map((m) => m is ReplacementSeriesAvailable || m is OriginalSeriesAvailable),
            );
            return vm;
          },
          dispose: (_, vm) {
            final notificationVM = DI.get<NotificationPriorityQueueViewModel>();
            notificationVM.removeStream(type: .illegalSegmentNoReplacement);
            notificationVM.removeStream(type: .illegalSegmentWithReplacement);
            vm.dispose();
          },
        ),
        ProxyProvider<JourneyPositionViewModel, DepartureAuthorizationViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return DepartureAuthorizationViewModel(
              journeyPositionStream: journeyPositionVM.model,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider2<
          JourneyPositionViewModel,
          NotificationPriorityQueueViewModel,
          DepartureDispatchNotificationViewModel
        >(
          lazy: false,
          update: (_, journeyPositionVM, notificationVM, prev) {
            if (prev != null) return prev;
            return DepartureDispatchNotificationViewModel(
              sferaRepo: DI.get(),
              notificationVM: notificationVM,
              journeyPositionStream: journeyPositionVM.model,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider2<JourneyViewModel, JourneySettingsViewModel, LineSpeedViewModel>(
          update: (_, journeyViewModel, settingsVM, prev) {
            if (prev != null) return prev;
            return LineSpeedViewModel(
              journeyViewModel: journeyViewModel,
              journeySettingsViewModel: settingsVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider2<JourneyViewModel, JourneyPositionViewModel, ShortTermChangeViewModel>(
          update: (_, journeyViewModel, journeyPositionViewModel, prev) {
            if (prev != null) return prev;
            return ShortTermChangeViewModel(
              journeyViewModel: journeyViewModel,
              journeyPositionViewModel: journeyPositionViewModel,
            );
          },
        ),
        ProxyProvider3<
          JourneyViewModel,
          JourneyPositionViewModel,
          NotificationPriorityQueueViewModel,
          SuspiciousSegmentViewModel
        >(
          lazy: false,
          update: (_, journeyVM, journeyPositionVM, notificationVM, prev) {
            if (prev != null) return prev;
            return SuspiciousSegmentViewModel(
              journeyViewModel: journeyVM,
              journeyPositionViewModel: journeyPositionVM,
              notificationVM: notificationVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider<LineSpeedViewModel, CalculatedSpeedViewModel>(
          update: (_, lineSpeedVM, prev) {
            if (prev != null) return prev;
            return CalculatedSpeedViewModel(
              journeyViewModel: journeyViewModel,
              lineSpeedViewModel: lineSpeedVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider3<
          JourneyPositionViewModel,
          LineSpeedViewModel,
          NotificationPriorityQueueViewModel,
          AdvisedSpeedViewModel
        >(
          lazy: false,
          update: (_, journeyPositionVM, lineSpeedViewModel, notificationVM, prev) {
            if (prev != null) return prev;
            return AdvisedSpeedViewModel(
              journeyPositionStream: journeyPositionVM.model,
              notificationVM: notificationVM,
              lineSpeedViewModel: lineSpeedViewModel,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider4<
          JourneyPositionViewModel,
          PunctualityViewModel,
          AdvisedSpeedViewModel,
          CalculatedSpeedViewModel,
          ChronographViewModel
        >(
          update: (_, journeyPositionVM, punctualityVM, advisedSpeedVM, calculatedSpeedVM, prev) {
            if (prev != null) return prev;
            return ChronographViewModel(
              journeyPositionStream: journeyPositionVM.model,
              punctualityStream: punctualityVM.model,
              advisedSpeedModelStream: advisedSpeedVM.model,
              calculatedSpeedViewModel: calculatedSpeedVM,
              journeyViewModel: journeyViewModel,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider5<
          JourneyViewModel,
          JourneyPositionViewModel,
          JourneySettingsViewModel,
          DetailModalViewModel,
          NotificationPriorityQueueViewModel,
          BrakeLoadSlipViewModel
        >(
          lazy: false,
          update: (_, journeyVM, positionVM, settingsVM, detailModalVM, notificationVM, prev) {
            if (prev != null) return prev;
            return BrakeLoadSlipViewModel(
              journeyViewModel: journeyVM,
              journeyPositionViewModel: positionVM,
              formationRepository: DI.get(),
              notificationViewModel: notificationVM,
              journeySettingsViewModel: settingsVM,
              detailModalViewModel: detailModalVM,
              connectivityManager: DI.get(),
              checkForUpdates: true,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider6<
          JourneyViewModel,
          JourneySettingsViewModel,
          CollapsibleRowsViewModel,
          JourneyPositionViewModel,
          DetailModalViewModel,
          DecisiveGradientViewModel,
          JourneyTableViewModel
        >(
          update: (_, journeyVM, settingsVM, collapsibleRowsVM, positionVM, detailModalVM, decisiveGradientVM, prev) {
            if (prev != null) return prev;
            final navigationVM = DI.get<JourneyNavigationViewModel>();
            return JourneyTableViewModel(
              journeyViewModel: journeyViewModel,
              settingsVM: settingsVM,
              collapsibleRowsVM: collapsibleRowsVM,
              positionVM: positionVM,
              detailModalVM: detailModalVM,
              decisiveGradientVM: decisiveGradientVM,
              navigationVM: navigationVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider2<JourneyPositionViewModel, JourneyTableAdvancementViewModel, TourSystemLinkVisibilityViewModel>(
          lazy: false,
          update: (_, journeyPositionVM, journeyTableAdvancementVM, prev) {
            if (prev != null) return prev;
            return TourSystemLinkVisibilityViewModel(
              journeyViewModel: journeyViewModel,
              journeyPositionViewModel: journeyPositionVM,
              journeyTableAdvancementViewModel: journeyTableAdvancementVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
      ],
      child: Builder(builder: builder),
    );
  }
}
