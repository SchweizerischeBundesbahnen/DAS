import 'package:app/pages/journey/train_journey/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_row_controller.dart';
import 'package:app/widgets/table/das_row_controller_wrapper.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class CalculatedSpeedCellBody extends StatelessWidget {
  static const String zeroSpeedContent = '\u{2013}'; // en dash '–'
  static const Key nonEmptyKey = Key('CalculatedSpeedCellBodyNonEmptyKey');
  static const Key generalKey = Key('CalculatedSpeedCellBodyGeneralKey');

  const CalculatedSpeedCellBody({
    required this.metadata,
    required this.settings,
    required this.order,
    required this.showSpeedBehavior,
    this.isNextStop = false,
    super.key,
  });

  final Metadata metadata;
  final TrainJourneySettings settings;
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

        final shouldResolvePrevious = _shouldResolvePrevious(state) && !metadata.calculatedSpeeds.containsKey(order);
        final calculatedSpeed = metadata.calculatedSpeeds[order];
        SingleSpeed? resolvedCalculatedSpeed =
            calculatedSpeed ?? (shouldResolvePrevious ? _calculatedSpeedFromPrev : null);

        if (resolvedCalculatedSpeed == null) return DASTableCell.emptyBuilder;

        final resolvedLineSpeed = _resolvedTrainSeriesSpeed(
          resolvePrevious: showSpeedBehavior == ShowSpeedBehavior.alwaysOrPreviousOnStickiness,
        );

        final isSpeedReducedDueToLineSpeed = resolvedCalculatedSpeed.isLargerThan(resolvedLineSpeed);
        resolvedCalculatedSpeed = _min(resolvedLineSpeed, resolvedCalculatedSpeed);

        final color = isNextStop ? SBBColors.white : ThemeUtil.getColor(context, SBBColors.metal, SBBColors.white);

        return Text(
          key: nonEmptyKey,
          resolvedCalculatedSpeed.value == '0' ? zeroSpeedContent : resolvedCalculatedSpeed.value,
          // TODO Currently the reduced lineSpeed color is set to SBBColors.white. After an exchange with UX this should be changed to a newly defined color.
          style: isSpeedReducedDueToLineSpeed ? DASTextStyles.largeLight.copyWith(color: color) : null,
        );
      },
    );
  }

  bool _shouldResolvePrevious(DASRowState state) {
    return switch (showSpeedBehavior) {
      ShowSpeedBehavior.alwaysOrPreviousOnStickiness =>
        state == DASRowState.sticky || state == DASRowState.firstVisibleRow,
      ShowSpeedBehavior.alwaysOrPrevious => true,
      _ => false,
    };
  }

  SingleSpeed? _resolvedTrainSeriesSpeed({bool resolvePrevious = false}) {
    final inEtcsLevel2Segment = metadata.nonStandardTrackEquipmentSegments.isInEtcsLevel2Segment(order);
    if (inEtcsLevel2Segment) return null;

    var trainSeriesSpeeds = metadata.lineSpeeds[order];
    if (trainSeriesSpeeds == null && resolvePrevious) {
      trainSeriesSpeeds = metadata.lineSpeeds[metadata.lineSpeeds.lastKeyBefore(order)];
    }

    final selectedBreakSeries = settings.resolvedBreakSeries(metadata);
    return trainSeriesSpeeds
            .speedFor(
              selectedBreakSeries?.trainSeries,
              breakSeries: selectedBreakSeries?.breakSeries,
            )
            ?.speed
        as SingleSpeed?;
  }

  SingleSpeed? get _calculatedSpeedFromPrev =>
      metadata.calculatedSpeeds[metadata.calculatedSpeeds.lastKeyBefore(order)];

  SingleSpeed _min(SingleSpeed? resolvedLineSpeed, SingleSpeed resolvedCalculatedSpeed) {
    if (resolvedLineSpeed == null) return resolvedCalculatedSpeed;
    if (resolvedLineSpeed.isIllegal) return resolvedCalculatedSpeed;
    return SingleSpeed(value: _numericMin(resolvedCalculatedSpeed.value, resolvedLineSpeed.value));
  }

  String _numericMin(String a, String b) => int.parse(a) > int.parse(b) ? b : a;
}

// extension

extension _SingleSpeedExtension on SingleSpeed {
  bool isLargerThan(SingleSpeed? other) {
    if (other == null) return false;
    if (other.isIllegal) return false;
    return int.parse(value) > int.parse(other.value);
  }
}
