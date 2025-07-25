import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:app/widgets/table/das_row_controller.dart';
import 'package:app/widgets/table/das_row_controller_wrapper.dart' hide DASRowState;
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class LineSpeedCellBody extends StatelessWidget {
  const LineSpeedCellBody({
    required this.metadata,
    required this.config,
    required this.order,
    this.showSpeedBehavior = ShowSpeedBehavior.never,
    super.key,
  });

  final Metadata metadata;
  final TrainJourneySettings config;
  final int order;
  final ShowSpeedBehavior showSpeedBehavior;

  @override
  Widget build(BuildContext context) {
    return switch (showSpeedBehavior) {
      ShowSpeedBehavior.always => SpeedDisplay(speed: _resolvedTrainSeriesSpeed()?.speed),
      ShowSpeedBehavior.never => DASTableCell.emptyBuilder,
      ShowSpeedBehavior.alwaysOrPreviousOnStickiness => StreamBuilder(
        stream: DASRowControllerWrapper.of(context)!.controller.rowState,
        initialData: DASRowControllerWrapper.of(context)!.controller.rowStateValue,
        builder: (context, snapshot) {
          final state = snapshot.requireData;

          final trainSeriesSpeed = _resolvedTrainSeriesSpeed(
            resolvePrevious: state == DASRowState.sticky || state == DASRowState.almostSticky,
          );

          return SpeedDisplay(speed: trainSeriesSpeed?.speed);
        },
      ),
    };
  }

  TrainSeriesSpeed? _resolvedTrainSeriesSpeed({bool resolvePrevious = false}) {
    var trainSeriesSpeeds = metadata.lineSpeeds[order];
    if (trainSeriesSpeeds == null && resolvePrevious) {
      trainSeriesSpeeds = metadata.lineSpeeds[metadata.lineSpeeds.lastKeyBefore(order)];
    }

    final selectedBreakSeries = config.resolvedBreakSeries(metadata);
    return trainSeriesSpeeds.speedFor(
      selectedBreakSeries?.trainSeries,
      breakSeries: selectedBreakSeries?.breakSeries,
    );
  }
}

enum ShowSpeedBehavior { always, alwaysOrPreviousOnStickiness, never }
