import 'package:app/pages/journey/calculated_speed_view_model.dart';
import 'package:app/pages/journey/journey_table/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_row_controller.dart';
import 'package:app/widgets/table/das_row_controller_wrapper.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class CalculatedSpeedCellBody extends StatelessWidget {
  static const String zeroSpeedContent = '\u{2013}'; // en dash '–'
  static const Key nonEmptyKey = Key('CalculatedSpeedCellBodyNonEmptyKey');
  static const Key generalKey = Key('CalculatedSpeedCellBodyGeneralKey');

  const CalculatedSpeedCellBody({
    required this.order,
    required this.showSpeedBehavior,
    this.isNextStop = false,
    super.key,
  });

  final int order;
  final ShowSpeedBehavior showSpeedBehavior;
  final bool isNextStop;

  @override
  Widget build(BuildContext context) {
    if (showSpeedBehavior == ShowSpeedBehavior.never) {
      return DASTableCell.emptyBuilder;
    }
    return _speedContent(context);
  }

  Widget _speedContent(BuildContext context) {
    final rowController = DASRowControllerWrapper.of(context)!.controller;
    return StreamBuilder(
      key: generalKey,
      stream: rowController.rowState,
      initialData: rowController.rowStateValue,
      builder: (context, snapshot) {
        final state = snapshot.requireData;

        final calculatedSpeedViewModel = context.read<CalculatedSpeedViewModel>();
        final calculatedSpeed = calculatedSpeedViewModel.getCalculatedSpeedForOrder(order);

        if (calculatedSpeed.speed == null) return DASTableCell.emptyBuilder;
        final speed = calculatedSpeed.speed!;

        if (!_shouldShowPrevious(state) && (calculatedSpeed.isSameAsPrevious || calculatedSpeed.isPrevious)) {
          return DASTableCell.emptyBuilder;
        }

        final isSpeedReducedDueToLineSpeed = calculatedSpeed.isReducedDueToLineSpeed;

        final reducedColor = isNextStop ? SBBColors.cement : SBBColors.metal;
        final color = isNextStop ? SBBColors.white : null;

        return Text(
          key: nonEmptyKey,
          speed.value == '0' ? zeroSpeedContent : speed.value,
          style: DASTextStyles.largeLight.copyWith(color: isSpeedReducedDueToLineSpeed ? reducedColor : color),
        );
      },
    );
  }

  bool _shouldShowPrevious(DASRowState state) {
    return switch (showSpeedBehavior) {
      ShowSpeedBehavior.alwaysOrPreviousOnStickiness =>
        state == DASRowState.sticky || state == DASRowState.firstVisibleRow,
      ShowSpeedBehavior.alwaysOrPrevious => true,
      _ => false,
    };
  }
}
