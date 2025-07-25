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

  final bool hasAdditionalInformation;
  final bool singleLine;
  final TextStyle textStyle;
  final Speed? speed;

  const SpeedDisplay({
    this.hasAdditionalInformation = false,
    this.singleLine = false,
    this.textStyle = DASTextStyles.largeRoman,
    this.speed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (speed == null) return DASTableCell.emptyBuilder;

    return DotIndicator(
      show: hasAdditionalInformation,
      offset: _dotIndicatorOffset(speed!),
      child: switch (speed!) {
        final IncomingOutgoingSpeed s => singleLine ? _rowSpeed(context, s) : _columnSpeed(context, s),
        final GraduatedSpeed _ || final SingleSpeed _ => _visualizedSpeeds(key: incomingSpeedsKey, speeds: speed!),
      },
    );
  }

  Widget _rowSpeed(BuildContext context, IncomingOutgoingSpeed ioSpeed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _visualizedSpeeds(key: incomingSpeedsKey, speeds: ioSpeed.incoming),
        Text(
          ' / ',
          style: textStyle,
        ),
        _visualizedSpeeds(key: outgoingSpeedsKey, speeds: ioSpeed.outgoing),
      ],
    );
  }

  Widget _columnSpeed(BuildContext context, IncomingOutgoingSpeed ioSpeed) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _visualizedSpeeds(key: incomingSpeedsKey, speeds: ioSpeed.incoming),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: Divider(color: Theme.of(context).colorScheme.onSurface, height: 1.0),
        ),
        _visualizedSpeeds(key: outgoingSpeedsKey, speeds: ioSpeed.outgoing),
      ],
    );
  }

  Widget _visualizedSpeeds({required Speed speeds, Key? key}) {
    final List<SingleSpeed> singleSpeeds = switch (speeds) {
      final GraduatedSpeed g => g.speeds,
      final SingleSpeed s => [s],
      final IncomingOutgoingSpeed _ => throw UnimplementedError(),
    };
    if (singleSpeeds.hasSquaredOrCircled) {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: singleSpeeds
            .map((speed) => _speedText(speed))
            .withDivider(
              Text('-', style: textStyle),
            )
            .toList(),
      );
    }
    return Text(
      key: key,
      singleSpeeds.toJoinedString(),
      style: textStyle,
    );
  }

  Widget _speedText(SingleSpeed speed) {
    return Builder(
      builder: (context) {
        final squaredOrCircled = speed.isCircled || speed.isSquared;
        return Container(
          key: squaredOrCircled ? (speed.isCircled ? circledSpeedKey : squaredSpeedKey) : null,
          padding: EdgeInsets.all(1.0),
          decoration: squaredOrCircled
              ? BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.onSurface),
                  borderRadius: speed.isCircled ? BorderRadius.circular(sbbDefaultSpacing) : BorderRadius.zero,
                )
              : null,
          child: Text(
            speed.value,
            style: textStyle.copyWith(height: 0),
          ),
        );
      },
    );
  }

  Offset _dotIndicatorOffset(Speed resolvedSpeed) => switch (resolvedSpeed) {
    final IncomingOutgoingSpeed _ => const Offset(0, 0),
    final GraduatedSpeed _ || final SingleSpeed _ => const Offset(0, -sbbDefaultSpacing * 0.5),
  };
}

// extensions

extension _SpeedIterableX on List<SingleSpeed> {
  String toJoinedString({String divider = '-'}) => map((it) => it.value).join(divider);

  bool get hasSquaredOrCircled => any((it) => it.isSquared || it.isCircled);
}
