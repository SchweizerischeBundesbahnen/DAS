import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedCellBody extends StatelessWidget {
  static const String _dash = '\u{2013}';

  const AdvisedSpeedCellBody({
    required this.speed,
    super.key,
  });

  final SingleSpeed speed;

  @override
  Widget build(BuildContext context) {
    final resolvedAdvisedSpeed = speed.value == '0' ? _dash : speed.value;
    return Text(key: key, resolvedAdvisedSpeed);
  }
}
