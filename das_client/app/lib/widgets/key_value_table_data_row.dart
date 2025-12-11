import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class KeyValueTableDataRow extends StatelessWidget {
  const KeyValueTableDataRow(
    this.label,
    this.value, {
    super.key,
    this.hasChange = false,
    this.labelStyle,
    this.valueStyle,
    this.shownChangeIndicator = true,
  });

  const KeyValueTableDataRow.title(String label, {Key? key, bool hasChange = false})
    : this(label, null, key: key, labelStyle: DASTextStyles.smallBold, hasChange: hasChange);

  const KeyValueTableDataRow.empty({Key? key}) : this('', null, key: key);

  final String label;
  final String? value;
  final bool hasChange;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final bool shownChangeIndicator;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Row(
        children: [
          _wrappedLabel(),
          SizedBox(width: sbbDefaultSpacing * 0.5),
          Container(
            constraints: BoxConstraints(minWidth: 40),
            child: Padding(
              padding: shownChangeIndicator ? const EdgeInsets.only(right: sbbDefaultSpacing * 0.75) : EdgeInsets.zero,
              child: Align(
                alignment: Alignment.centerRight,
                child: _valueText(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _wrappedLabel() {
    final labelText = Text(
      label,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: labelStyle ?? DASTextStyles.smallRoman,
    );

    return hasChange && shownChangeIndicator && value == null
        ? DotIndicator(
            offset: Offset(0, -sbbDefaultSpacing * 0.75),
            child: labelText,
          )
        : Expanded(child: labelText);
  }

  Widget _valueText() {
    final text = Text(
      maxLines: 2,
      value ?? '',
      overflow: TextOverflow.ellipsis,
      style: valueStyle ?? (hasChange && shownChangeIndicator ? DASTextStyles.smallBold : DASTextStyles.smallRoman),
    );

    return hasChange && shownChangeIndicator && value != null
        ? DotIndicator(
            offset: Offset(0, -sbbDefaultSpacing * 0.75),
            child: text,
          )
        : text;
  }
}
