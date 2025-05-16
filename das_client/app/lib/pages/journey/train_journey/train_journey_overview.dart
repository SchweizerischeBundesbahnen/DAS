import 'package:app/bloc/train_journey_cubit.dart';
import 'package:app/bloc/ux_testing_cubit.dart';
import 'package:app/di.dart';
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
import 'package:app/sound/koa_sound.dart';
import 'package:app/sound/sound.dart';
import 'package:app/sound/warn_app_sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            final controller = context.trainJourneyCubit.automaticAdvancementController;
            return DetailModalViewModel(onOpen: () => controller.resetScrollTimer());
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
            journeyStream: bloc.journeyStream,
          ),
          dispose: (context, vm) => vm.dispose(),
        )
      ],
      builder: (context, child) => BlocProvider.value(
        value: DI.get<UxTestingCubit>(),
        child: BlocListener<UxTestingCubit, UxTestingState>(
          listener: _handleUxEvents,
          child: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final detailModalController = context.read<DetailModalViewModel>().controller;
    return Listener(
      onPointerDown: (_) => detailModalController.resetAutomaticClose(),
      onPointerUp: (_) => detailModalController.resetAutomaticClose(),
      child: Row(
        children: [
          Expanded(child: _content()),
          DetailModalSheet(),
        ],
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

  void _handleUxEvents(BuildContext context, UxTestingState state) {
    if (state is UxTestingEventReceived) {
      if (state.event.isWarn) {
        final Sound sound = WarnAppSound();
        sound.play();
        showWarnFunctionModalSheet(context);
      } else if (state.event.isKoa && state.event.value == KoaState.waitCancelled.name) {
        final Sound sound = KoaSound();
        sound.play();
      }
    }
  }
}
