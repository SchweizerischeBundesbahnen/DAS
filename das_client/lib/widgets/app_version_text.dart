import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionText extends StatelessWidget {
  const AppVersionText({super.key, required this.color});

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
