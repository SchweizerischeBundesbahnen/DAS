import 'package:app/pages/journey/train_journey/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/widgets/speed_display.dart';
import 'package:app/widgets/table/das_row_controller.dart';
import 'package:app/widgets/table/das_row_controller_wrapper.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class LineSpeedCellBody extends StatelessWidget {
  const LineSpeedCellBody({
    required this.metadata,
    required this.config,
    required this.order,
    this.showSpeedBehavior = ShowSpeedBehavior.never,
    this.isNextStop = false,
    super.key,
  });

  final Metadata metadata;
  final TrainJourneySettings config;
  final int order;
  final ShowSpeedBehavior showSpeedBehavior;
  final bool isNextStop;

  @override
  Widget build(BuildContext context) {
    return switch (showSpeedBehavior) {
      ShowSpeedBehavior.always => SpeedDisplay(
        speed: _resolvedTrainSeriesSpeed()?.speed,
        isNextStop: isNextStop,
      ),
      ShowSpeedBehavior.alwaysOrPrevious => SpeedDisplay(
        speed: _resolvedTrainSeriesSpeed(resolvePrevious: true)?.speed,
        isNextStop: isNextStop,
      ),
      ShowSpeedBehavior.never => DASTableCell.emptyBuilder,
      ShowSpeedBehavior.alwaysOrPreviousOnStickiness => _handledStickinessSpeedDisplay(context),
    };
  }

  Widget _handledStickinessSpeedDisplay(BuildContext context) {
    final rowController = DASRowControllerWrapper.of(context)!.controller;
    return StreamBuilder(
      stream: rowController.rowState,
      initialData: rowController.rowStateValue,
      builder: (context, snapshot) {
        final state = snapshot.requireData;

        final trainSeriesSpeed = _resolvedTrainSeriesSpeed(
          resolvePrevious: state == DASRowState.sticky || state == DASRowState.firstVisibleRow,
        );

        return SpeedDisplay(
          speed: trainSeriesSpeed?.speed,
          isNextStop: isNextStop,
        );
      },
    );
  }

  TrainSeriesSpeed? _resolvedTrainSeriesSpeed({bool resolvePrevious = false}) {
    var trainSeriesSpeeds = metadata.lineSpeeds[order];
    final selectedBreakSeries = config.resolvedBreakSeries(metadata);

    if (!hasSpeed(trainSeriesSpeeds, selectedBreakSeries) && resolvePrevious) {
      var lastKey = metadata.lineSpeeds.lastKeyBefore(order);
      while (!hasSpeed(trainSeriesSpeeds, selectedBreakSeries) && lastKey != null) {
        trainSeriesSpeeds = metadata.lineSpeeds[lastKey];
        lastKey = metadata.lineSpeeds.lastKeyBefore(lastKey);
      }
    }

    return trainSeriesSpeeds.speedFor(
      selectedBreakSeries?.trainSeries,
      breakSeries: selectedBreakSeries?.breakSeries,
    );
  }

  bool hasSpeed(Iterable<TrainSeriesSpeed>? speeds, BreakSeries? selectedBreakSeries) {
    return speeds?.speedFor(
          selectedBreakSeries?.trainSeries,
          breakSeries: selectedBreakSeries?.breakSeries,
        ) !=
        null;
  }
}
