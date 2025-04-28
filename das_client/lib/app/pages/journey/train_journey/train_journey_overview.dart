import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/bloc/ux_testing_cubit.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal/detail_modal.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal/detail_modal_view_model.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/detail_modal/service_point_modal/service_point_modal_view_model.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/notification/koa_notification.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/notification/maneuver_notification.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/warn_function_modal_sheet.dart';
import 'package:das_client/app/widgets/assets.dart';
import 'package:das_client/di.dart';
import 'package:das_client/model/journey/koa_state.dart';
import 'package:das_client/util/sound.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class TrainJourneyOverview extends StatelessWidget {
  const TrainJourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(
          create: (context) {
            final controller = context.trainJourneyCubit.automaticAdvancementController;
            return DetailModalViewModel(automaticAdvancementController: controller);
          },
          dispose: (context, vm) => vm.dispose(),
        ),
        Provider(
          create: (_) => ServicePointModalViewModel(),
          dispose: (context, vm) => vm.dispose(),
        ),
      ],
      child: BlocProvider.value(
        value: DI.get<UxTestingCubit>(),
        child: BlocListener<UxTestingCubit, UxTestingState>(
          listener: _handleUxEvents,
          child: _body(),
        ),
      ),
    );
  }

  Widget _body() {
    return Builder(builder: (context) {
      final modalController = context.read<DetailModalViewModel>().controller;
      return Listener(
        onPointerDown: (_) => modalController.resetAutomaticClose(),
        onPointerUp: (_) => modalController.resetAutomaticClose(),
        child: Row(
          children: [
            Expanded(child: _content()),
            DetailModalSheet(),
          ],
        ),
      );
    });
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
        Sound.play(AppAssets.warnappWarn);
        showWarnFunctionModalSheet(context);
      } else if (state.event.isKoa && state.event.value == KoaState.waitCancelled.name) {
        Sound.play(AppAssets.soundKoaWaitCanceled);
      }
    }
  }
}
