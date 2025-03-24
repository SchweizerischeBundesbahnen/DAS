import 'package:das_client/app/bloc/ux_testing_cubit.dart';
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

class TrainJourneyOverview extends StatelessWidget {
  const TrainJourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: DI.get<UxTestingCubit>(),
      child: BlocListener<UxTestingCubit, UxTestingState>(
        listener: (context, state) {
          if (state is UxTestingEventReceived) {
            if (state.event.isWarn) {
              Sound.play(AppAssets.warnappWarn);
              showWarnFunctionModalSheet(context);
            } else if (state.event.isKoa && state.event.value == KoaState.waitCancelled.name) {
              Sound.play(AppAssets.soundKoaWaitCanceled);
            }
          }
        },
        child: const Column(
          children: [
            Header(),
            ManeuverNotification(),
            KoaNotification(),
            Expanded(child: TrainJourney()),
          ],
        ),
      ),
    );
  }
}
