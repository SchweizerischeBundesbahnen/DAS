import 'package:app/pages/journey/train_journey/das_table_speed_view_model.dart';
import 'package:app/pages/journey/train_journey/widgets/table/service_point_row.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/stickyheader/sticky_header.dart';
import 'package:app/widgets/stickyheader/sticky_level.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedCellBody extends StatelessWidget {
  static const String zeroSpeedContent = '\u{2013}'; // en dash '–'

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

  static const Key nonEmptyKey = Key('AdvisedSpeedCellBodyNonEmptyKey');
  static const Key generalKey = Key('AdvisedSpeedCellBodyGeneralKey');

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      key: generalKey,
      listenable: StickyHeader.of(context)!.controller,
      builder: (context, _) {
        final isSticky = _isSticky(context);

        SingleSpeed? resolvedCalculatedSpeed = calculatedSpeed ?? (isSticky ? _calculatedSpeedFromPrev(context) : null);
        final resolvedLineSpeed = lineSpeed ?? (isSticky ? _lineSpeedFromPrev(context) : null);
        if (resolvedCalculatedSpeed == null) return DASTableCell.emptyBuilder;

        resolvedCalculatedSpeed = _min(resolvedLineSpeed, resolvedCalculatedSpeed);
        return Text(
          key: nonEmptyKey,
          resolvedCalculatedSpeed.value == '0' ? zeroSpeedContent : resolvedCalculatedSpeed.value,
          style: isSpeedReducedDueToLineSpeed ? DASTextStyles.largeLight.copyWith(color: SBBColors.metal) : null,
        );
      },
    );
  }

  bool _isSticky(BuildContext context) {
    // stickiness only relevant if any speed null
    if (calculatedSpeed != null && lineSpeed != null) return false;

    final stickyController = StickyHeader.of(context)!.controller;
    return stickyController.headerIndexes[StickyLevel.first] == rowIndex ||
        (stickyController.nextHeaderIndex[StickyLevel.first] == rowIndex &&
            ((stickyController.headerOffsets[StickyLevel.first] ?? 0) < (-ServicePointRow.baseRowHeight * 0.33)));
  }

  SingleSpeed? _calculatedSpeedFromPrev(BuildContext context) =>
      context.read<DASTableSpeedViewModel>().previousCalculatedSpeed(rowIndex);

  SingleSpeed? _lineSpeedFromPrev(BuildContext context) =>
      context.read<DASTableSpeedViewModel>().previousLineSpeed(rowIndex);

  SingleSpeed _min(SingleSpeed? resolvedLineSpeed, SingleSpeed resolvedCalculatedSpeed) {
    if (resolvedLineSpeed == null) return resolvedCalculatedSpeed;
    if (resolvedLineSpeed.isIllegal) return resolvedCalculatedSpeed;
    return SingleSpeed(value: _numericMin(resolvedCalculatedSpeed.value, resolvedLineSpeed.value));
  }

  String _numericMin(String a, String b) => int.parse(a) > int.parse(b) ? b : a;
}
