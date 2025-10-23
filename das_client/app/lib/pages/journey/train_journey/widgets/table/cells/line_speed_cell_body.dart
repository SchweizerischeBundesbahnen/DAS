import 'package:app/pages/journey/line_speed_view_model.dart';
import 'package:app/pages/journey/resolved_train_series_speed.dart';
import 'package:app/pages/journey/train_journey/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:app/widgets/table/das_row_controller.dart';
import 'package:app/widgets/table/das_row_controller_wrapper.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LineSpeedCellBody extends StatelessWidget {
  const LineSpeedCellBody({
    required this.order,
    this.showSpeedBehavior = ShowSpeedBehavior.never,
    this.isNextStop = false,
    super.key,
  });

  final int order;
  final ShowSpeedBehavior showSpeedBehavior;
  final bool isNextStop;

  @override
  Widget build(BuildContext context) {
    final lineSpeedViewModel = context.read<LineSpeedViewModel>();
    final resolvedSpeed = lineSpeedViewModel.getResolvedSpeedForOrder(order);

    return switch (showSpeedBehavior) {
      ShowSpeedBehavior.always => SpeedDisplay(
        speed: resolvedSpeed.isPrevious ? null : resolvedSpeed.speed?.speed,
        isNextStop: isNextStop,
      ),
      ShowSpeedBehavior.alwaysOrPrevious => SpeedDisplay(
        speed: resolvedSpeed.speed?.speed,
        isNextStop: isNextStop,
      ),
      ShowSpeedBehavior.never => DASTableCell.emptyBuilder,
      ShowSpeedBehavior.alwaysOrPreviousOnStickiness => _handledStickinessSpeedDisplay(context, resolvedSpeed),
    };
  }

  Widget _handledStickinessSpeedDisplay(BuildContext context, ResolvedTrainSeriesSpeed resolvedSpeed) {
    if (!resolvedSpeed.isPrevious) {
      return SpeedDisplay(
        speed: resolvedSpeed.speed?.speed,
        isNextStop: isNextStop,
      );
    } else {
      final rowController = DASRowControllerWrapper.of(context)!.controller;
      return StreamBuilder(
        stream: rowController.rowState,
        initialData: rowController.rowStateValue,
        builder: (context, snapshot) {
          final state = snapshot.requireData;

          return SpeedDisplay(
            speed: state == DASRowState.sticky || state == DASRowState.firstVisibleRow
                ? resolvedSpeed.speed?.speed
                : null,
            isNextStop: isNextStop,
          );
        },
      );
    }
  }
}
