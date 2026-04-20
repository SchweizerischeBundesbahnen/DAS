import 'package:app/util/device_id_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        return GestureDetector(
          onTap: () async {
            await Clipboard.setData(ClipboardData(text: deviceId));
            if (context.mounted) {
              SBBToast.of(context).show(title: 'Copied to Clipboard: $deviceId');
            }
          },
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Text('Device Id', style: sbbTextStyle.lightStyle.xSmall.copyWith(color: color)),
              SelectableText(deviceId, style: sbbTextStyle.boldStyle.small.copyWith(color: color)),
            ],
          ),
        );
      },
    );
  }
}
