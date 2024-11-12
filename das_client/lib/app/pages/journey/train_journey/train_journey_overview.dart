import 'package:das_client/app/pages/journey/train_journey/widgets/header/adl_notification.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/header.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/train_journey.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
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
          margin: EdgeInsets.fromLTRB(sbbDefaultSpacing * 0.5, 0, sbbDefaultSpacing * 0.5, sbbDefaultSpacing),
        ),
        Expanded(child: TrainJourney()),
      ],
    );
  }
}
