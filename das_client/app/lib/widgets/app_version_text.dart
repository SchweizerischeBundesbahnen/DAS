import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class AppVersionText extends StatelessWidget {
  const AppVersionText({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        final info = snapshot.data as PackageInfo;
        return Row(
          children: [
            Icon(SBBIcons.circle_information_small, color: color),
            const SizedBox(width: SBBSpacing.xSmall),
            Text(
              info.version,
              style: DASTextStyles.smallLight.copyWith(color: color),
            ),
          ],
        );
      },
    );
  }
}
