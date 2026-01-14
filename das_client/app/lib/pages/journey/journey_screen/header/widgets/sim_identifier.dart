import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';

class SimIdentifier extends StatelessWidget {
  static const Key simKey = Key('sim');

  const SimIdentifier({super.key, this.textStyle = DASTextStyles.xLargeRoman});

  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) => Text(key: simKey, 'SIM', style: textStyle);
}
