import 'package:app/pages/journey/journey_screen/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/pages/journey/journey_validation/multi_line_speed_view_model.dart';
import 'package:app/pages/journey/view_model/model/resolved_train_series_speed.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/row/das_row_controller_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sfera/component.dart';

// TODO: remove this with https://github.com/SchweizerischeBundesbahnen/DAS/issues/2734
// Hint: start by removing complete dir
class MultiLineSpeedCellBody extends StatelessWidget {
  const MultiLineSpeedCellBody({
    required this.order,
    this.showSpeedBehavior = .never,
    this.isNextStop = false,
    super.key,
  });

  final int order;
  final ShowSpeedBehavior showSpeedBehavior;
  final bool isNextStop;

  @override
  Widget build(BuildContext context) {
    final multiLineSpeedViewModel = context.read<MultiLineSpeedViewModel>();
    final resolvedSpeeds = multiLineSpeedViewModel.getResolvedSpeedsForOrder(order);

    return switch (showSpeedBehavior) {
      .always => _row(resolvedSpeeds.map((it) => it.isPrevious ? null : it.speed?.speed).toList(growable: false)),
      .alwaysOrPrevious => _row(resolvedSpeeds.map((it) => it.speed?.speed).toList(growable: false)),
      .never => DASTableCell.emptyBuilder,
      .alwaysOrPreviousOnStickiness => _handledStickinessSpeedDisplay(context, resolvedSpeeds),
    };
  }

  Widget _handledStickinessSpeedDisplay(BuildContext context, List<ResolvedTrainSeriesSpeed> resolvedSpeeds) {
    if (!resolvedSpeeds.any((it) => it.isPrevious)) {
      return _row(resolvedSpeeds.map((it) => it.speed?.speed).toList(growable: false));
    }

    final rowController = DASRowControllerWrapper.of(context)!.controller;
    return StreamBuilder(
      stream: rowController.rowState,
      initialData: rowController.rowStateValue,
      builder: (context, snapshot) {
        final state = snapshot.requireData;
        final showPrevious = state == .sticky || state == .firstVisibleRow;

        return _row(
          resolvedSpeeds
              .map((it) => showPrevious || !it.isPrevious ? it.speed?.speed : null)
              .toList(growable: false),
        );
      },
    );
  }

  Widget _row(List<Speed?> speeds) {
    return Row(
      mainAxisAlignment: .spaceEvenly,
      children: speeds.map((speed) => SpeedDisplay(speed: speed, isNextStop: isNextStop)).toList(growable: false),
    );
  }
}
