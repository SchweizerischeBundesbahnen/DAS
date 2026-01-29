import 'package:app/util/device_id_info.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DeviceIdText extends StatelessWidget {
  const DeviceIdText({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DeviceIdInfo.getDeviceId(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final deviceId = snapshot.data ?? '';
        return Text(deviceId, style: sbbTextStyle.lightStyle.small.copyWith(color: color));
      },
    );
  }
}
