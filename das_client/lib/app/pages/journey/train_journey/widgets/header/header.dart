import 'package:das_client/app/pages/journey/train_journey/magic_secret_shhh/pages/flappy_screen.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/main_container.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/header/time_container.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _background(context),
        _containers(context),
      ],
    );
  }

  Widget _background(BuildContext context) {
    final primary = Theme.of(context).colorScheme.secondary;
    return Container(
      color: primary,
      height: sbbDefaultSpacing * 2,
    );
  }

  Widget _containers(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => FlappyScreen()));
      },
      child: const Row(
        children: [
          Expanded(child: MainContainer()),
          TimeContainer(),
        ],
      ),
    );
  }
}
