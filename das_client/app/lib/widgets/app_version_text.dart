import 'package:app/app_info/app_info.dart';
import 'package:app/di/di.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class AppVersionText extends StatelessWidget {
  const AppVersionText({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final appInfo = DI.get<AppInfo>();
    return Column(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        Text('App Version', style: sbbTextStyle.lightStyle.xSmall.copyWith(color: color)),
        Text(appInfo.version, style: sbbTextStyle.boldStyle.small.copyWith(color: color)),
      ],
    );
  }
}
