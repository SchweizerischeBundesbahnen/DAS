import 'package:das_client/app/bloc/train_journey_cubit.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:flutter/material.dart';

class TrainJourneyOverview extends StatelessWidget {
  const TrainJourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        context.trainJourneyCubit.automaticAdvancementController.onTouch();
      },
      onPointerUp: (_) {
        context.trainJourneyCubit.automaticAdvancementController.onTouch();
      },
      child: const Column(
        children: [
          Header(),
          Expanded(child: TrainJourney()),
        ],
      ),
    );
  }
}
