import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SimIdentifier extends StatelessWidget {
  static const Key simKey = Key('sim');

  SimIdentifier({super.key, TextStyle? textStyle}) : textStyle = textStyle ?? sbbTextStyle.romanStyle.xLarge;

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) => Text(key: simKey, 'SIM', style: textStyle);
}
