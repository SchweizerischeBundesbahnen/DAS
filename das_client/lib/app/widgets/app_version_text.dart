import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionText extends StatelessWidget {
  const AppVersionText({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          final PackageInfo info = snapshot.data as PackageInfo;
          return Row(
            children: [
              Icon(
                SBBIcons.circle_information_small,
                color: color,
              ),
              const SizedBox(
                width: sbbDefaultSpacing / 2,
              ),
              Text(info.version,
                  style: SBBTextStyles.smallLight.copyWith(color: color)),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
