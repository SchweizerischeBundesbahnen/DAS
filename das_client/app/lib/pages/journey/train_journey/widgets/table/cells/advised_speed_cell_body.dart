import 'package:app/pages/journey/train_journey/widgets/table/cells/show_speed_behaviour.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/train_journey_settings.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/table/das_table_theme.dart';
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
    return _backgroundStack(
      context,
      _content(context),
    );
  }

  Widget _content(BuildContext context) {
    if (showSpeedBehavior == ShowSpeedBehavior.never) {
      return DASTableCell.emptyBuilder;
    }

    final inEtcsLevel2Segment = metadata.nonStandardTrackEquipmentSegments.isInEtcsLevel2Segment(order);
    late final advisedSpeed = metadata.advisedSpeedSegments.appliesToOrder(order).firstOrNull;
    if (inEtcsLevel2Segment || advisedSpeed == null) return DASTableCell.emptyBuilder;

    var speed = advisedSpeed.speed;
    if (advisedSpeed is VelocityMaxAdvisedSpeedSegment) {
      speed = _resolvedTrainSeriesSpeed();
    }

    return Text(
      speed?.value ?? '',
      key: nonEmptyKey,
      style: isNextStop ? DASTextStyles.largeRoman.copyWith(color: SBBColors.white) : DASTextStyles.largeRoman,
    );
  }

  SingleSpeed? _resolvedTrainSeriesSpeed() {
    var trainSeriesSpeeds = metadata.lineSpeeds[order];
    trainSeriesSpeeds ??= metadata.lineSpeeds[metadata.lineSpeeds.lastKeyBefore(order)];

    final selectedBreakSeries = settings.resolvedBreakSeries(metadata);
    return trainSeriesSpeeds
            .speedFor(
              selectedBreakSeries?.trainSeries,
              breakSeries: selectedBreakSeries?.breakSeries,
            )
            ?.speed
        as SingleSpeed?;
  }

  Widget _backgroundStack(BuildContext context, Widget child) {
    final horizontalBorderWidth =
        DASTableTheme.of(context)?.data.tableBorder?.horizontalInside.width ?? sbbDefaultSpacing;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: -horizontalBorderWidth * 2,
          bottom: -horizontalBorderWidth * 2,
          left: 0,
          right: 0,
          child: Container(
            color: SBBColors.iron,
          ),
        ),
        Center(
          child: child,
        ),
      ],
    );
  }
}
