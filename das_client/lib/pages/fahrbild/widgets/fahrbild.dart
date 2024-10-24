import 'package:das_client/pages/fahrbild/widgets/header/header.dart';
import 'package:das_client/pages/fahrbild/widgets/train_journey.dart';
import 'package:flutter/material.dart';

class Fahrbild extends StatelessWidget {
  const Fahrbild({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Header(),
        Expanded(child: TrainJourney()),
      ],
    );
  }
}
