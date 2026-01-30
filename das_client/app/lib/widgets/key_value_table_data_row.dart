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
    this.showChangeIndicator = true,
  });

  KeyValueTableDataRow.title(String label, {Key? key, bool hasChange = false})
    : this(label, null, key: key, labelStyle: sbbTextStyle.boldStyle.small, hasChange: hasChange);

  const KeyValueTableDataRow.empty({Key? key}) : this('', null, key: key);

  final String label;
  final String? value;
  final bool hasChange;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final bool showChangeIndicator;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: Row(
        children: [
          _wrappedLabel(),
          SizedBox(width: SBBSpacing.xSmall),
          Container(
            constraints: BoxConstraints(minWidth: 40),
            child: Padding(
              padding: showChangeIndicator ? const EdgeInsets.only(right: SBBSpacing.small) : EdgeInsets.zero,
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
      style: labelStyle ?? sbbTextStyle.romanStyle.small,
    );

    return hasChange && showChangeIndicator && value == null
        ? DotIndicator(
            offset: Offset(0, -SBBSpacing.small),
            child: labelText,
          )
        : Expanded(child: labelText);
  }

  Widget _valueText() {
    final text = Text(
      maxLines: 2,
      value ?? '',
      overflow: TextOverflow.ellipsis,
      style:
          valueStyle ??
          (hasChange && showChangeIndicator ? sbbTextStyle.boldStyle.small : sbbTextStyle.romanStyle.small),
    );

    return hasChange && showChangeIndicator && value != null
        ? DotIndicator(
            offset: Offset(0, -SBBSpacing.small),
            child: text,
          )
        : text;
  }
}
