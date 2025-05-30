import 'package:app/di.dart';
import 'package:app/pages/journey/train_journey/ux_testing_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/additional_speed_restriction_modal/additional_speed_restriction_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/koa_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/notification/maneuver_notification.dart';
import 'package:app/pages/journey/train_journey/widgets/table/arrival_departure_time/arrival_departure_time_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:app/pages/journey/train_journey/widgets/warn_function_modal_sheet.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:app/sound/koa_sound.dart';
import 'package:app/sound/sound.dart';
import 'package:app/sound/warn_app_sound.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfera/component.dart';

class TrainJourneyOverview extends StatelessWidget {
  const TrainJourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) {
            final controller = context.read<TrainJourneyViewModel>().automaticAdvancementController;
            return DetailModalViewModel(automaticAdvancementController: controller);
          },
          dispose: (context, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ServicePointModalViewModel(),
          dispose: (context, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => AdditionalSpeedRestrictionModalViewModel(),
          dispose: (context, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ArrivalDepartureTimeViewModel(
            journeyStream: context.read<TrainJourneyViewModel>().journey,
          ),
          dispose: (context, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => UxTestingViewModel(sferaService: DI.get()),
          dispose: (context, vm) => vm.dispose(),
        ),
      ],
      builder: (context, child) => _body(context),
    );
  }

  Widget _body(BuildContext context) {
    final uxTestingViewModel = context.read<UxTestingViewModel>();
    final detailModalController = context.read<DetailModalViewModel>().controller;
    return Listener(
      onPointerDown: (_) => detailModalController.resetAutomaticClose(),
      onPointerUp: (_) => detailModalController.resetAutomaticClose(),
      child: StreamBuilder(
        stream: uxTestingViewModel.uxTestingEvents,
        builder: (context, snapshot) {
          _handleUxEvents(context, snapshot.data);

          return Row(
            children: [
              Expanded(child: _content()),
              DetailModalSheet(),
            ],
          );
        },
      ),
    );
  }

  Widget _content() {
    return Column(
      children: [
        Header(),
        ManeuverNotification(),
        KoaNotification(),
        Expanded(child: TrainJourney()),
      ],
    );
  }

  void _handleUxEvents(BuildContext context, UxTestingEvent? event) {
    if (event == null) return;

    if (event.isWarn) {
      final Sound sound = WarnAppSound();
      sound.play();
      showWarnFunctionModalSheet(context);
    } else if (event.isKoa && event.value == KoaState.waitCancelled.name) {
      final Sound sound = KoaSound();
      sound.play();
    }
  }
}
