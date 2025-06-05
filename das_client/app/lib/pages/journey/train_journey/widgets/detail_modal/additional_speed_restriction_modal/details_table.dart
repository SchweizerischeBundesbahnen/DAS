import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
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
      padding: EdgeInsets.symmetric(horizontal: sbbDefaultSpacing),
      decoration: BoxDecoration(
        color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.black),
        borderRadius: BorderRadius.circular(sbbDefaultSpacing * 0.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
    final cellPadding = sbbDefaultSpacing * 0.5;
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: _maxTitleWidth + cellPadding * 2,
            padding: EdgeInsets.all(cellPadding),
            decoration: BoxDecoration(
              border: Border(bottom: bottomBorder),
            ),
            child: Text(
              title,
              maxLines: 1,
              style: DASTextStyles.mediumBold,
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.all(sbbDefaultSpacing * 0.5),
              decoration: BoxDecoration(
                border: Border(bottom: bottomBorder, left: borderSide),
              ),
              child: Text(data ?? '-', style: DASTextStyles.mediumRoman),
            ),
          ),
        ],
      ),
    );
  }

  static double _calculateMaxTextWidth(Iterable<String> texts) {
    double maxWidth = 0.0;
    for (final text in texts) {
      final textSpan = TextSpan(text: text, style: DASTextStyles.mediumBold);
      final textPainter = TextPainter(text: textSpan, maxLines: 1, textDirection: TextDirection.ltr);
      textPainter.layout();
      maxWidth = maxWidth < textPainter.width ? textPainter.width : maxWidth;
    }
    return maxWidth;
  }
}
