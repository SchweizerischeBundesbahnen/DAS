import 'package:das_client/pages/fahrt/fahrbild/widgets/header/main_container.dart';
import 'package:das_client/pages/fahrt/fahrbild/widgets/header/time_container.dart';
import 'package:flutter/material.dart';

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
      height: 32.0,
    );
  }

  Widget _containers(BuildContext context) {
    return const Row(
      children: [
        Expanded(child: MainContainer()),
        TimeContainer(),
      ],
    );
  }
}
