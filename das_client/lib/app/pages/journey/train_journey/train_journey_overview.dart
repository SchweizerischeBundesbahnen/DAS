import 'package:das_client/app/pages/journey/train_journey/widgets/header/adl_notification.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:flutter/material.dart';

// TODO: handle extraLarge font sizes (diff to figma) globally.
// TODO: Add testing
class TrainJourneyOverview extends StatelessWidget {
  const TrainJourneyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Header(),
        ADLNotification(
          message: 'VMax fahren bis Wettingen',
          margin: EdgeInsets.fromLTRB(8, 0, 8, 16),
        ),
        Expanded(child: TrainJourney()),
      ],
    );
  }
}
