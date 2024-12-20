import 'package:das_client/util/device_id_info.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

class DeviceIdText extends StatelessWidget {
  const DeviceIdText({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DeviceIdInfo.getDeviceId(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final deviceId = snapshot.data as String? ?? '';
          return Text(deviceId, style: SBBTextStyles.smallLight.copyWith(color: color));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
