import 'package:app/widgets/das_text_styles.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:app/widgets/table/das_table_cell.dart';
import 'package:app/widgets/widget_extensions.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class SpeedDisplay extends StatelessWidget {
  static const Key incomingSpeedsKey = Key('incomingSpeeds');
  static const Key outgoingSpeedsKey = Key('outgoingSpeeds');
  static const Key circledSpeedKey = Key('graduatedSpeedCircled');
  static const Key squaredSpeedKey = Key('graduatedSpeedSquared');

  const SpeedDisplay({
    this.hasAdditionalInformation = false,
    this.singleLine = false,
    this.summarizedCurve = false,
    this.textStyle = DASTextStyles.largeRoman,
    this.speed,
    this.isNextStop = false,
    super.key,
  });

  final bool hasAdditionalInformation;
  final bool singleLine;
  final bool summarizedCurve;
  final TextStyle textStyle;
  final Speed? speed;
  final bool isNextStop;

  @override
  Widget build(BuildContext context) {
    if (speed == null) return DASTableCell.emptyBuilder;

    return DotIndicator(
      show: hasAdditionalInformation,
      offset: _dotIndicatorOffset(speed!),
      isNextStop: isNextStop,
      child: switch (speed!) {
        final SummarizedCurvesSpeed _ => _visualizedSpeeds(speeds: speed!),
        final IncomingOutgoingSpeed s => singleLine ? _rowSpeed(context, s) : _columnSpeed(context, s),
        final GraduatedSpeed _ || final SingleSpeed _ => _visualizedSpeeds(key: incomingSpeedsKey, speeds: speed!),
      },
    );
  }

  Widget _rowSpeed(BuildContext context, IncomingOutgoingSpeed ioSpeed) {
    return Row(
      mainAxisSize: .min,
      crossAxisAlignment: .center,
      children: [
        _visualizedSpeeds(key: incomingSpeedsKey, speeds: ioSpeed.incoming),
        Text(
          ' / ',
          style: _textStyle,
        ),
        _visualizedSpeeds(key: outgoingSpeedsKey, speeds: ioSpeed.outgoing),
      ],
    );
  }

  Widget _columnSpeed(BuildContext context, IncomingOutgoingSpeed ioSpeed) {
    return Column(
      mainAxisSize: .min,
      children: [
        _visualizedSpeeds(key: incomingSpeedsKey, speeds: ioSpeed.incoming),
        Padding(
          padding: const .symmetric(vertical: 2.0),
          child: Divider(color: isNextStop ? SBBColors.white : Theme.of(context).colorScheme.onSurface, height: 1.0),
        ),
        _visualizedSpeeds(key: outgoingSpeedsKey, speeds: ioSpeed.outgoing),
      ],
    );
  }

  Widget _visualizedSpeeds({required Speed speeds, Key? key}) {
    final List<SingleSpeed> singleSpeeds = switch (speeds) {
      final SummarizedCurvesSpeed sc => sc.speeds,
      final GraduatedSpeed g => g.speeds,
      final SingleSpeed s => [s],
      final IncomingOutgoingSpeed _ => throw UnimplementedError(),
    };
    if (singleSpeeds.hasSquaredOrCircled) {
      return Row(
        key: key,
        mainAxisSize: .min,
        children: singleSpeeds
            .map((speed) => _speedText(speed))
            .withDivider(
              Text('-', style: _textStyle),
            )
            .toList(),
      );
    }
    return Text(
      key: key,
      singleSpeeds.toJoinedString(),
      style: _textStyle,
    );
  }

  Widget _speedText(SingleSpeed speed) {
    return Builder(
      builder: (context) {
        final squaredOrCircled = speed.isCircled || speed.isSquared;
        return Container(
          key: squaredOrCircled ? (speed.isCircled ? circledSpeedKey : squaredSpeedKey) : null,
          padding: .all(1.0),
          decoration: squaredOrCircled
              ? BoxDecoration(
                  border: Border.all(color: isNextStop ? SBBColors.white : Theme.of(context).colorScheme.onSurface),
                  borderRadius: speed.isCircled ? BorderRadius.circular(sbbDefaultSpacing) : BorderRadius.zero,
                )
              : null,
          child: Text(
            speed.value,
            style: _textStyle.copyWith(height: 0),
          ),
        );
      },
    );
  }

  Offset _dotIndicatorOffset(Speed resolvedSpeed) => switch (resolvedSpeed) {
    final SummarizedCurvesSpeed _ => const Offset(0, 0),
    final IncomingOutgoingSpeed _ => const Offset(0, 0),
    final GraduatedSpeed _ || final SingleSpeed _ => const Offset(0, -sbbDefaultSpacing * 0.5),
  };

  TextStyle get _textStyle => isNextStop ? textStyle.copyWith(color: SBBColors.white) : textStyle;
}

extension _SpeedIterableX on List<SingleSpeed> {
  String toJoinedString({String divider = '-'}) => map((it) => it.value).join(divider);

  bool get hasSquaredOrCircled => any((it) => it.isSquared || it.isCircled);
}
