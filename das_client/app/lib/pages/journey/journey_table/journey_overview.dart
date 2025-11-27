import 'package:app/di/di.dart';
import 'package:app/pages/journey/break_load_slip/break_load_slip_view_model.dart';
import 'package:app/pages/journey/calculated_speed_view_model.dart';
import 'package:app/pages/journey/journey_table/advised_speed/advised_speed_notification.dart';
import 'package:app/pages/journey/journey_table/advised_speed/advised_speed_view_model.dart';
import 'package:app/pages/journey/journey_table/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/journey_table/header/chronograph/chronograph_view_model.dart';
import 'package:app/pages/journey/journey_table/header/connectivity/connectivity_view_model.dart';
import 'package:app/pages/journey/journey_table/header/departure_authorization/departure_authorization_view_model.dart';
import 'package:app/pages/journey/journey_table/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/journey_table/punctuality/punctuality_view_model.dart';
import 'package:app/pages/journey/journey_table/ux_testing_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/header/header.dart';
import 'package:app/pages/journey/journey_table/widgets/journey_navigation_buttons.dart';
import 'package:app/pages/journey/journey_table/widgets/journey_table.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/koa_notification.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/maneuver_notification.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/replacement_series/replacement_series_notification.dart';
import 'package:app/pages/journey/journey_table/widgets/notification/replacement_series/replacement_series_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/warn_function_modal_sheet.dart';
import 'package:app/pages/journey/journey_table_view_model.dart';
import 'package:app/pages/journey/line_speed_view_model.dart';
import 'package:app/pages/journey/warn_app_view_model.dart';
import 'package:app/sound/das_sounds.dart';
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
        _warnappNotification(context),
        Expanded(
          child: Stack(
            children: [
              JourneyTable(),
              Align(alignment: Alignment.bottomCenter, child: JourneyNavigationButtons()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _warnappNotification(BuildContext context) {
    return StreamBuilder(
      stream: context.read<WarnAppViewModel>().warnappEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _triggerWarnappNotification(context);
        }

        return SizedBox.shrink();
      },
    );
  }

  Widget _uxTestingEventListener(BuildContext context) {
    return StreamBuilder(
      stream: context.read<UxTestingViewModel>().uxTestingEvents,
      builder: (context, snapshot) {
        final event = snapshot.data;

        if (event?.isWarn ?? false) {
          _triggerWarnappNotification(context);
        }

        return SizedBox.shrink();
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
          create: (_) => PunctualityViewModel(journeyStream: journeyTableViewModel.journey),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (context) => DetailModalViewModel(
            automaticAdvancementController: journeyTableViewModel.automaticAdvancementController,
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ServicePointModalViewModel(localRegulationHtmlGenerator: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => AdditionalSpeedRestrictionModalViewModel(),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ArrivalDepartureTimeViewModel(journeyStream: journeyTableViewModel.journey),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => UxTestingViewModel(sferaService: DI.get(), ruFeatureProvider: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ConnectivityViewModel(connectivityManager: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => LineSpeedViewModel(journeyTableViewModel: journeyTableViewModel),
          dispose: (_, vm) => vm.dispose(),
        ),

        // PROXY  PROVIDERS
        ProxyProvider<PunctualityViewModel, JourneyPositionViewModel>(
          update: (_, punctualityVM, prev) {
            if (prev != null) return prev;
            return JourneyPositionViewModel(
              journeyStream: journeyTableViewModel.journey,
              punctualityStream: punctualityVM.model,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider<JourneyPositionViewModel, CollapsibleRowsViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return CollapsibleRowsViewModel(
              journeyStream: journeyTableViewModel.journey,
              journeyPositionStream: journeyPositionVM.model,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider<JourneyPositionViewModel, AdvisedSpeedViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return AdvisedSpeedViewModel(
              journeyStream: journeyTableViewModel.journey,
              journeyPositionStream: journeyPositionVM.model,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider<JourneyPositionViewModel, ReplacementSeriesViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return ReplacementSeriesViewModel(
              journeyTableViewModel: journeyTableViewModel,
              journeyPositionViewModel: journeyPositionVM,
            );
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        ProxyProvider<JourneyPositionViewModel, DepartureAuthorizationViewModel>(
          update: (_, journeyPositionVM, prev) {
            if (prev != null) return prev;
            return DepartureAuthorizationViewModel(
              journeyStream: journeyTableViewModel.journey,
              journeyPositionStream: journeyPositionVM.model,
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
              journeyStream: journeyTableViewModel.journey,
              journeyPositionStream: journeyPositionVM.model,
              punctualityStream: punctualityVM.model,
              advisedSpeedModelStream: advisedSpeedVM.model,
              calculatedSpeedViewModel: calculatedSpeedVM,
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
      child: Builder(builder: builder),
    );
  }
}
