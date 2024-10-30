import 'package:das_client/pages/fahrt/fahrbild/widgets/header/adl_notification.dart';
import 'package:das_client/pages/fahrt/fahrbild/widgets/header/header.dart';
import 'package:das_client/pages/fahrt/fahrbild/widgets/train_journey.dart';
import 'package:flutter/material.dart';

// TODO: handle extraLarge font sizes (diff to figma) globally.
// TODO: discuss general naming in DEV team
// TODO: Add testing
class Fahrbild extends StatelessWidget {
  const Fahrbild({super.key});

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
