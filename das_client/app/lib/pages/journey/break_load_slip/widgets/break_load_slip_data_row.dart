import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';

class BreakLoadSlipDataRow extends StatelessWidget {
  const BreakLoadSlipDataRow(this.label, this.value, {super.key, this.labelStyle, this.valueStyle});

  final String label;
  final String? value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: labelStyle ?? DASTextStyles.smallRoman,
        ),
        Text(
          value ?? '',
          style: valueStyle ?? DASTextStyles.smallRoman,
        ),
      ],
    );
  }
}
