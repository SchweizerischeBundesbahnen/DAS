import 'package:app/theme/theme_util.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DetailsTable extends StatelessWidget {
  static const Key detailsTableKey = Key('detailsTable');

  DetailsTable({required this.data, super.key}) : _maxTitleWidth = _calculateMaxTextWidth(data.keys);

  final Map<String, String?> data;
  final double _maxTitleWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: detailsTableKey,
      padding: .symmetric(horizontal: SBBSpacing.medium),
      decoration: BoxDecoration(
        color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
        borderRadius: BorderRadius.circular(SBBSpacing.xSmall),
      ),
      child: Column(
        mainAxisSize: .min,
        children: data.entries
            .mapIndexed((index, row) => _tableRow(context, row.key, row.value, isLastItem: index == data.length - 1))
            .toList(),
      ),
    );
  }

  Widget _tableRow(BuildContext context, String title, String? data, {bool isLastItem = false}) {
    final borderColor = ThemeUtil.getColor(context, SBBColors.cloud, SBBColors.granite);
    final borderSide = BorderSide(color: borderColor);
    final bottomBorder = isLastItem ? BorderSide.none : borderSide;
    final cellPadding = SBBSpacing.xSmall;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: .stretch,
        children: [
          Container(
            width: _maxTitleWidth + cellPadding * 2,
            padding: .all(cellPadding),
            decoration: BoxDecoration(
              border: Border(bottom: bottomBorder),
            ),
            child: Text(
              title,
              maxLines: 1,
              style: sbbTextStyle.boldStyle.medium,
            ),
          ),
          Expanded(
            child: Container(
              padding: .all(SBBSpacing.xSmall),
              decoration: BoxDecoration(
                border: Border(bottom: bottomBorder, left: borderSide),
              ),
              child: Text(data ?? '-', style: sbbTextStyle.romanStyle.medium),
            ),
          ),
        ],
      ),
    );
  }

  static double _calculateMaxTextWidth(Iterable<String> texts) {
    double maxWidth = 0.0;
    for (final text in texts) {
      final textSpan = TextSpan(text: text, style: sbbTextStyle.boldStyle.medium);
      final textPainter = TextPainter(text: textSpan, maxLines: 1, textDirection: TextDirection.ltr);
      textPainter.layout();
      maxWidth = maxWidth < textPainter.width ? textPainter.width : maxWidth;
    }
    return maxWidth;
  }
}
