import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/bloc/ux_testing_cubit.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/maneuver_notification.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/warn_function_modal_sheet.dart';
import 'package:das_client/di.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TrainJourneyOverview extends StatelessWidget {
  const TrainJourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: DI.get<UxTestingCubit>()..initialize(),
      child: BlocListener<UxTestingCubit, UxTestingState>(
        listener: (context, state) {
          if (state is UxTestingEventReceived && state.event.isWarn) {
            _handleWarnEvent(context);
          }
        },
        child: const Column(
          children: [
            Header(),
            ManeuverNotification(),
            Expanded(child: TrainJourney()),
          ],
        ),
      ),
    );
  }

  Future<void> _handleWarnEvent(BuildContext context) async {
    final trainJourneyCubit = context.trainJourneyCubit;
    final activateManeuver = await showWarnFunctionModalSheet(context);
    if (activateManeuver == true) {
      trainJourneyCubit.setManeuverMode(true);
    }
  }
}
