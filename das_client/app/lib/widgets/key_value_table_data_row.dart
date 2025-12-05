import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class KeyValueTableDataRow extends StatelessWidget {
  const KeyValueTableDataRow(this.label, this.value, {super.key, this.labelStyle, this.valueStyle});

  const KeyValueTableDataRow.title(String label, {Key? key})
    : this(label, null, key: key, labelStyle: DASTextStyles.smallBold);

  const KeyValueTableDataRow.empty({Key? key}) : this('', null, key: key);

  final String label;
  final String? value;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: labelStyle ?? DASTextStyles.smallRoman,
            ),
          ),
          SizedBox(width: sbbDefaultSpacing * 0.5),
          Container(
            constraints: BoxConstraints(minWidth: 40),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                maxLines: 2,
                value ?? '',
                overflow: TextOverflow.ellipsis,
                style: valueStyle ?? DASTextStyles.smallRoman,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
