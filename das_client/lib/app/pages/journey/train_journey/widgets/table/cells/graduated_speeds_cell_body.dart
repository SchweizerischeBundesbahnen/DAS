import 'package:das_client/app/widgets/indicator_painter.dart';
import 'package:das_client/app/widgets/table/das_table_theme.dart';
import 'package:das_client/app/widgets/widget_extensions.dart';
import 'package:das_client/model/journey/speed.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class GraduatedSpeedsCellBody extends StatelessWidget {
  static const Key incomingSpeedsKey = Key('incomingSpeeds');
  static const Key outgoingSpeedsKey = Key('outgoingSpeeds');
  static const Key circledSpeedKey = Key('graduatedSpeedCircled');
  static const Key squaredSpeedKey = Key('graduatedSpeedSquared');
  static const Key indicatorKey = Key('indicatorKey');
  static const double _indicatorSize = 8.0;

  const GraduatedSpeedsCellBody({
    this.incomingSpeeds = const [],
    this.outgoingSpeeds = const [],
    this.hasAdditionalInformation = false,
    super.key,
  });

  final List<Speed> incomingSpeeds;
  final List<Speed> outgoingSpeeds;
  final bool hasAdditionalInformation;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: _buildSpeeds(context),
          ),
        ),
        if (hasAdditionalInformation)
          Positioned(
            top: 0,
            right: 0,
            child: CustomPaint(
              key: indicatorKey,
              painter: IndicatorPainter(color: Theme.of(context).colorScheme.primary),
              size: Size(_indicatorSize, _indicatorSize),
            ),
          )
      ],
    );
  }

  Widget _buildSpeeds(BuildContext context) {
    if (outgoingSpeeds.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _visualizedSpeeds(key: incomingSpeedsKey, speeds: incomingSpeeds),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Divider(color: Theme.of(context).colorScheme.onSurface, height: 1.0),
          ),
          _visualizedSpeeds(key: outgoingSpeedsKey, speeds: outgoingSpeeds),
        ],
      );
    }

    return _visualizedSpeeds(key: incomingSpeedsKey, speeds: incomingSpeeds);
  }

  Widget _visualizedSpeeds({required List<Speed> speeds, Key? key}) {
    if (speeds.hasSquaredOrCircled) {
      return Row(
        key: key,
        mainAxisSize: MainAxisSize.min,
        children: speeds.map((speed) => _speedText(speed)).withDivider(Text('-')).toList(),
      );
    }
    return Text(key: key, speeds.toJoinedString());
  }

  Widget _speedText(Speed speed) {
    return Builder(builder: (context) {
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
          speed.speed.toString(),
          style: DASTableTheme.of(context)?.data.dataTextStyle?.copyWith(height: 0),
        ),
      );
    });
  }
}

// extensions

extension _SpeedIterableX on Iterable<Speed> {
  String toJoinedString({String divider = '-'}) => map((it) => it.speed.toString()).join(divider);

  bool get hasSquaredOrCircled => any((it) => it.isSquared || it.isCircled);
}
