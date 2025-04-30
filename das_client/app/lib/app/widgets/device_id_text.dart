import 'package:app/app/widgets/das_text_styles.dart';
import 'package:app/util/device_id_info.dart';
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
          return Text(deviceId, style: DASTextStyles.smallLight.copyWith(color: color));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
