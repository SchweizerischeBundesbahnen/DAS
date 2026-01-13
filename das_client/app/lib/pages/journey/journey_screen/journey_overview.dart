import 'package:app/di/di.dart';
import 'package:app/pages/journey/break_load_slip/view_model/break_load_slip_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/chronograph_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/connectivity_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/view_model/departure_authorization_view_model.dart';
import 'package:app/pages/journey/journey_screen/header/widgets/header.dart';
import 'package:app/pages/journey/journey_screen/view_model/advised_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/calculated_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/departure_dispatch_notification_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/journey_table_advancement_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/line_speed_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/punctuality_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/replacement_series_view_model.dart';
import 'package:app/pages/journey/journey_screen/view_model/ux_testing_view_model.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_navigation_buttons.dart';
import 'package:app/pages/journey/journey_screen/widgets/journey_table.dart';
import 'package:app/pages/journey/journey_screen/widgets/notification/advised_speed_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/notification/break_load_slip_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/notification/departure_dispatch_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/notification/disturbance_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/notification/koa_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/notification/maneuver_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/notification/replacement_series_notification.dart';
import 'package:app/pages/journey/journey_screen/widgets/warn_function_modal_sheet.dart';
import 'package:app/pages/journey/view_model/disturbance_view_model.dart';
import 'package:app/pages/journey/view_model/journey_settings_view_model.dart';
import 'package:app/pages/journey/view_model/journey_table_view_model.dart';
import 'package:app/pages/journey/view_model/warn_app_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:app/widgets/stream_listener.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class JourneyOverview extends StatelessWidget {
  static const double horizontalPadding = sbbDefaultSpacing * 0.5;

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
              _uxTestingEventListener(context),
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
        AdvisedSpeedNotification(),
        ManeuverNotification(),
        KoaNotification(),
        ReplacementSeriesNotification(),
        DepartureDispatchNotification(),
        _warnAppNotification(context),
        BreakLoadSlipNotification(),
        DisturbanceNotification(),
        Expanded(
          child: Stack(
            children: [
              JourneyTable(),
              Align(alignment: .bottomCenter, child: JourneyNavigationButtons()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _warnAppNotification(BuildContext context) {
    return StreamListener(
      stream: context.read<WarnAppViewModel>().warnappEvents,
      onData: (data) {
        _triggerWarnappNotification(context);
      },
    );
  }

  Widget _uxTestingEventListener(BuildContext context) {
    return StreamListener(
      stream: context.read<UxTestingViewModel>().uxTestingEvents,
      onData: (data) {
        if (data.isWarn) {
          _triggerWarnappNotification(context);
        }
      },
    );
  }

  void _triggerWarnappNotification(BuildContext context) {
    DI.get<DASSounds>().warnApp.play();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showWarnFunctionModalSheet(
        context,
        onManeuverButtonPressed: () => context.read<WarnAppViewModel>().setManeuverMode(true),
      );
    });
  }
}

class _ProviderScope extends StatelessWidget {
  const _ProviderScope({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final journeyTableViewModel = context.read<JourneyTableViewModel>();
    return MultiProvider(
      providers: [
        Provider<PunctualityViewModel>(
          create: (_) => DI.get<PunctualityViewModel>(),
        ),
        Provider<JourneyPositionViewModel>(
          create: (_) => DI.get<JourneyPositionViewModel>(),
        ),
        Provider<JourneyTableAdvancementViewModel>(
          create: (_) => DI.get<JourneyTableAdvancementViewModel>(),
        ),
        Provider<ServicePointModalViewModel>(
          create: (_) => ServicePointModalViewModel(localRegulationHtmlGenerator: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<AdditionalSpeedRestrictionModalViewModel>(
          create: (_) => AdditionalSpeedRestrictionModalViewModel(),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<ArrivalDepartureTimeViewModel>(
          create: (_) => ArrivalDepartureTimeViewModel(),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<UxTestingViewModel>(
          create: (_) => UxTestingViewModel(sferaService: DI.get(), ruFeatureProvider: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider<ConnectivityViewModel>(
          create: (_) => ConnectivityViewModel(connectivityManager: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => DisturbanceViewModel(sferaRemoteRepo: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),

        // PROXY  PROVIDERS
        ProxyProvider<JourneyPositionViewModel, CollapsibleRowsViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return CollapsibleRowsViewModel(
              journeyPositionStream: journeyPositionVM.model,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider<JourneyPositionViewModel, AdvisedSpeedViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return AdvisedSpeedViewModel(
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

        ProxyProvider2<JourneyPositionViewModel, JourneySettingsViewModel, ReplacementSeriesViewModel>(
          update: (_, journeyPositionVM, settingsVM, prev) {
            if (prev != null) return prev;
            return ReplacementSeriesViewModel(
              journeyTableViewModel: journeyTableViewModel,
              journeyPositionViewModel: journeyPositionVM,
              journeySettingsViewModel: settingsVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
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
        ProxyProvider<JourneyPositionViewModel, DepartureDispatchNotificationViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return DepartureDispatchNotificationViewModel(
              sferaRemoteRepo: DI.get(),
              journeyPositionStream: journeyPositionVM.model,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider2<JourneyTableViewModel, JourneySettingsViewModel, LineSpeedViewModel>(
          update: (_, journeyTableViewModel, settingsVM, prev) {
            if (prev != null) return prev;
            return LineSpeedViewModel(
              journeyTableViewModel: journeyTableViewModel,
              journeySettingsViewModel: settingsVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider<LineSpeedViewModel, CalculatedSpeedViewModel>(
          update: (_, lineSpeedVM, prev) {
            if (prev != null) return prev;
            return CalculatedSpeedViewModel(
              journeyTableViewModel: journeyTableViewModel,
              lineSpeedViewModel: lineSpeedVM,
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
              journeyTableViewModel: journeyTableViewModel,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider4<
          JourneyTableViewModel,
          JourneyPositionViewModel,
          JourneySettingsViewModel,
          DetailModalViewModel,
          BreakLoadSlipViewModel
        >(
          update: (_, journeyVM, positionVM, settingsVM, detailModalVM, prev) {
            if (prev != null) return prev;
            return BreakLoadSlipViewModel(
              journeyTableViewModel: journeyVM,
              journeyPositionViewModel: positionVM,
              formationRepository: DI.get(),
              journeySettingsViewModel: settingsVM,
              detailModalViewModel: detailModalVM,
              connectivityManager: DI.get(),
              checkForUpdates: true,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
      ],
      child: Builder(builder: builder),
    );
  }
}
