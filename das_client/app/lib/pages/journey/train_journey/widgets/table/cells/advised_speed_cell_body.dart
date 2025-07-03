import 'package:app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedCellBody extends StatelessWidget {
  static const String _dash = '\u{2013}';

  const AdvisedSpeedCellBody({
    required this.rowIndex,
    this.calculatedSpeed,
    this.lineSpeed,
    this.isSpeedReducedDueToLineSpeed = false,
    super.key,
  });

  final int rowIndex;
  final SingleSpeed? calculatedSpeed;
  final SingleSpeed? lineSpeed;
  final bool isSpeedReducedDueToLineSpeed;

  @override
  Widget build(BuildContext context) {
    final isSticky = _isSticky(context);
    SingleSpeed? resolvedCalculatedSpeed = calculatedSpeed ?? (isSticky ? _calculatedSpeedFromPrev() : null);
    final resolvedLineSpeed = lineSpeed ?? (isSticky ? _lineSpeedFromPrev() : null);

    if (resolvedCalculatedSpeed == null) return DASTableCell.emptyBuilder;
    return Text(
      key: key,
      resolvedCalculatedSpeed.value == '0' ? _dash : resolvedCalculatedSpeed.value,
      style: isSpeedReducedDueToLineSpeed ? DASTextStyles.largeLight.copyWith(color: SBBColors.metal) : null,
    );
  }

  // if (lineSpeed != null) {
  // final ls = int.parse(lineSpeed.value);
  // final cs = int.parse(data.calculatedSpeed!.value);
  // isSpeedReducedDueToLineSpeed = cs > ls;
  // if (isSpeedReducedDueToLineSpeed) calculatedSpeed = lineSpeed;
  // }

  bool _isSticky(BuildContext context) {
    if (calculatedSpeed != null && lineSpeed != null) return false; // stickiness only relevant if any speed null

    final stickyController = StickyHeader.of(context)!.controller;
    return stickyController.headerIndexes[StickyLevel.first] == rowIndex ||
        (stickyController.nextHeaderIndex[StickyLevel.first] == rowIndex &&
            ((stickyController.headerOffsets[StickyLevel.first] ?? 0) < (-ServicePointRow.rowHeight * 0.33)));
  }

  Speed? _calculatedSpeedFromPrev() {}

  Speed? _lineSpeedFromPrev() {}
}
