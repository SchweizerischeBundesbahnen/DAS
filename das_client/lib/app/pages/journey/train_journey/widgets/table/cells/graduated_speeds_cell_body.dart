import 'package:das_client/app/widgets/table/das_table_theme.dart';
import 'package:das_client/app/widgets/widget_extensions.dart';
import 'package:das_client/model/journey/speed.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class GraduatedSpeedsCellBody extends StatelessWidget {
  static const Key incomingSpeedsKey = Key('incoming-speeds');
  static const Key outgoingSpeedsKey = Key('outgoing-speeds');
  static const Key circledSpeedKey = Key('graduated-speed-circled');
  static const Key squaredSpeedKey = Key('graduated-speed-squared');

  const GraduatedSpeedsCellBody({
    this.incomingSpeeds = const [],
    this.outgoingSpeeds = const [],
    super.key,
  });

  final List<Speed> incomingSpeeds;
  final List<Speed> outgoingSpeeds;

  @override
  Widget build(BuildContext context) {
    if (outgoingSpeeds.isNotEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _visualizedSpeeds(key: incomingSpeedsKey, speeds: incomingSpeeds),
          Divider(color: Theme.of(context).colorScheme.onSurface, height: 1.0),
          _visualizedSpeeds(key: outgoingSpeedsKey, speeds: outgoingSpeeds),
        ],
      );
    }

    return _visualizedSpeeds(key: incomingSpeedsKey, speeds: incomingSpeeds);
  }

  Widget _visualizedSpeeds({required List<Speed> speeds, Key? key}) {
    if (speeds.hasSquaredOrCircled()) {
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
        margin: EdgeInsets.symmetric(vertical: 1.0),
        padding: EdgeInsets.symmetric(horizontal: 1.0),
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

  bool hasSquaredOrCircled() => any((it) => it.isSquared || it.isCircled);
}
