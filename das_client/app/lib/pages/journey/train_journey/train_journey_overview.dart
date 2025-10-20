import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_notification.dart';
import 'package:app/pages/journey/train_journey/advised_speed/advised_speed_view_model.dart';
import 'package:app/pages/journey/train_journey/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/train_journey/header/chronograph/chronograph_view_model.dart';
import 'package:app/pages/journey/train_journey/header/connectivity/connectivity_view_model.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_view_model.dart';
import 'package:app/pages/journey/train_journey/punctuality/punctuality_view_model.dart';
import 'package:app/pages/journey/train_journey/ux_testing_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:app/pages/journey/train_journey/widgets/journey_navigation_buttons.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/koa_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/maneuver_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/replacement_series/replacement_series_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/replacement_series/replacement_series_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:app/pages/journey/train_journey/widgets/warn_function_modal_sheet.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/pages/journey/warn_app_view_model.dart';
import 'package:app/sound/das_sounds.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TrainJourneyOverview extends StatelessWidget {
  static const double horizontalPadding = sbbDefaultSpacing * 0.5;

  const TrainJourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    final trainJourneyViewModel = context.read<TrainJourneyViewModel>();
    final punctualityViewModel = PunctualityViewModel(journeyStream: trainJourneyViewModel.journey);
    final journeyPositionViewModel = JourneyPositionViewModel(
      journeyStream: trainJourneyViewModel.journey,
      punctualityStream: punctualityViewModel.model,
    );
    return MultiProvider(
      providers: [
        Provider(
          create: (context) {
            final controller = trainJourneyViewModel.automaticAdvancementController;
            return DetailModalViewModel(automaticAdvancementController: controller);
          },
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => punctualityViewModel,
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => CollapsibleRowsViewModel(
            journeyStream: trainJourneyViewModel.journey,
            journeyPositionStream: journeyPositionViewModel.model,
          ),
          dispose: (context, vm) => vm.dispose(),
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
          create: (_) => ArrivalDepartureTimeViewModel(
            journeyStream: trainJourneyViewModel.journey,
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => UxTestingViewModel(sferaService: DI.get(), ruFeatureProvider: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => AdvisedSpeedViewModel(
            journeyStream: trainJourneyViewModel.journey,
            journeyPositionStream: journeyPositionViewModel.model,
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => journeyPositionViewModel,
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ConnectivityViewModel(connectivityManager: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ReplacementSeriesViewModel(
            trainJourneyViewModel: trainJourneyViewModel,
            journeyPositionViewModel: journeyPositionViewModel,
          ),
          dispose: (_, vm) => vm.dispose(),
        ),
      ],
      builder: (context, child) {
        return Provider(
          create: (_) => ChronographViewModel(
            journeyStream: trainJourneyViewModel.journey,
            journeyPositionStream: context.read<JourneyPositionViewModel>().model,
            punctualityStream: context.read<PunctualityViewModel>().model,
            advisedSpeedModelStream: context.read<AdvisedSpeedViewModel>().model,
          ),
          dispose: (_, vm) => vm.dispose(),
          builder: (context, child) => _body(context),
        );
      },
    );
  }

  Widget _body(BuildContext context) {
    final detailModalController = context.read<DetailModalViewModel>().controller;
    return Listener(
      onPointerDown: (_) => detailModalController.resetAutomaticClose(),
      onPointerUp: (_) => detailModalController.resetAutomaticClose(),
      child: StreamBuilder(
        stream: context.read<UxTestingViewModel>().uxTestingEvents,
        builder: (context, snapshot) {
          _handleUxEvents(context, snapshot.data);

          return Row(
            children: [
              Expanded(child: _content(context)),
              DetailModalSheet(),
            ],
          );
        },
      ),
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
              TrainJourney(),
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

  void _triggerWarnappNotification(BuildContext context) {
    DI.get<DASSounds>().warnApp.play();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showWarnFunctionModalSheet(
        context,
        onManeuverButtonPressed: () => context.read<WarnAppViewModel>().setManeuverMode(true),
      );
    });
  }

  void _handleUxEvents(BuildContext context, UxTestingEvent? event) {
    if (event == null) return;

    if (event.isWarn) {
      _triggerWarnappNotification(context);
    } else if (event.isKoa && event.value == KoaState.waitCancelled.name) {
      DI.get<DASSounds>().koa.play();
    }
  }
}
