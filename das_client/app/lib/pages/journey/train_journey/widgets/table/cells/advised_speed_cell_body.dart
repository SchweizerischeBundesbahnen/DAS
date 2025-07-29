import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_row_controller.dart';
import 'package:app/widgets/table/das_row_controller_wrapper.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedCellBody extends StatelessWidget {
  static const String zeroSpeedContent = '\u{2013}'; // en dash '–'
  static const Key nonEmptyKey = Key('AdvisedSpeedCellBodyNonEmptyKey');
  static const Key generalKey = Key('AdvisedSpeedCellBodyGeneralKey');

  const AdvisedSpeedCellBody({
    required this.metadata,
    required this.settings,
    required this.order,
    super.key,
  });

  final Metadata metadata;
  final TrainJourneySettings settings;
  final int order;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      key: generalKey,
      stream: DASRowControllerWrapper.of(context)!.controller.rowState,
      initialData: DASRowControllerWrapper.of(context)!.controller.rowStateValue,
      builder: (context, snapshot) {
        final state = snapshot.requireData;
        final isSticky = state == DASRowState.sticky || state == DASRowState.almostSticky;

        final calculatedSpeed = metadata.calculatedSpeeds[order];

        SingleSpeed? resolvedCalculatedSpeed = calculatedSpeed ?? (isSticky ? _calculatedSpeedFromPrev : null);
        final resolvedLineSpeed = _resolvedTrainSeriesSpeed(resolvePrevious: true);
        if (resolvedCalculatedSpeed == null) return DASTableCell.emptyBuilder;

        final isSpeedReducedDueToLineSpeed = _isBLargerThanA(a: resolvedLineSpeed, b: resolvedCalculatedSpeed);
        resolvedCalculatedSpeed = _min(resolvedLineSpeed, resolvedCalculatedSpeed);
        return Text(
          key: nonEmptyKey,
          resolvedCalculatedSpeed.value == '0' ? zeroSpeedContent : resolvedCalculatedSpeed.value,
          style: isSpeedReducedDueToLineSpeed ? DASTextStyles.largeLight.copyWith(color: SBBColors.metal) : null,
        );
      },
    );
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

  bool _isBLargerThanA({required SingleSpeed? a, required SingleSpeed b}) {
    if (a == null) return false;
    if (a.isIllegal) return false;
    return int.parse(b.value) > int.parse(a.value);
  }
}
