import 'package:app/di/di.dart';
import 'package:app/pages/journey/train_journey/collapsible_rows_view_model.dart';
import 'package:app/pages/journey/train_journey/ux_testing_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/chronograph/chronograph_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:app/pages/journey/train_journey/widgets/journey_navigation_buttons.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/adl_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/adl_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/koa_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/maneuver_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:app/pages/journey/train_journey/widgets/warn_function_modal_sheet.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/sound/koa_sound.dart';
import 'package:app/sound/warn_app_sound.dart';
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
          create: (_) => CollapsibleRowsViewModel(sferaRemoteRepo: DI.get()),
          dispose: (context, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ServicePointModalViewModel(),
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
          create: (_) => UxTestingViewModel(sferaService: DI.get()),
          dispose: (_, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => AdlViewModel(journeyStream: trainJourneyViewModel.journey),
          dispose: (_, vm) => vm.dispose(),
        ),
      ],
      builder: (context, child) {
        return Provider(
          create: (_) => ChronographViewModel(
            journeyStream: trainJourneyViewModel.journey,
            adlViewModel: context.read<AdlViewModel>(),
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
        ADLNotification(),
        ManeuverNotification(),
        KoaNotification(),
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
      stream: context.read<TrainJourneyViewModel>().warnappEvents,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _triggerWarnappNotification(context);
        }

        return SizedBox.shrink();
      },
    );
  }

  void _triggerWarnappNotification(BuildContext context) {
    WarnAppSound().play();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      showWarnFunctionModalSheet(
        context,
        onManeuverButtonPressed: () => context.read<TrainJourneyViewModel>().setManeuverMode(true),
      );
    });
  }

  void _handleUxEvents(BuildContext context, UxTestingEvent? event) {
    if (event == null) return;

    if (event.isWarn) {
      _triggerWarnappNotification(context);
    } else if (event.isKoa && event.value == KoaState.waitCancelled.name) {
      KoaSound().play();
    }
  }
}
