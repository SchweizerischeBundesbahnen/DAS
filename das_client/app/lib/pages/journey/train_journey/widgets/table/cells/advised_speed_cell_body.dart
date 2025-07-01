import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedCellBody extends StatelessWidget {
  const AdvisedSpeedCellBody({
    required this.speed,
    super.key,
  });

  final SingleSpeed speed;

  @override
  Widget build(BuildContext context) {
    return Text(key: key, speed.value);
  }
}
