import 'package:app/di/di.dart';
import 'package:app/di/scope_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class MqttBrokerText extends StatelessWidget {
  const MqttBrokerText({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final connectedToMock = DI.getOrNull<ScopeHandler>()?.isInStack<SferaMockScope>() ?? true;

    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text('MQTT Broker', style: sbbTextStyle.lightStyle.xSmall.copyWith(color: color)),
        Text(connectedToMock ? 'Mock' : 'TMS VAD', style: sbbTextStyle.boldStyle.small.copyWith(color: color)),
      ],
    );
  }
}
