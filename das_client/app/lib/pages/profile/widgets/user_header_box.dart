import 'package:app/di/di.dart';
import 'package:app/theme/theme_util.dart';
import 'package:auth/component.dart';
import 'package:flutter/cupertino.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class UserHeaderBox extends StatelessWidget {
  const UserHeaderBox({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DI.get<Authenticator>().user(),
      builder: (context, asyncSnapshot) {
        final subtitleColor = ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite);

        return SBBHeaderbox.custom(
          child: Row(
            spacing: SBBSpacing.small,
            children: [
              const Icon(SBBIcons.user_small),
              Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text(asyncSnapshot.data?.displayName ?? '', style: SBBTextStyles.mediumBold),
                  Text(
                    asyncSnapshot.data?.userId ?? '',
                    style: SBBTextStyles.smallLight.copyWith(color: subtitleColor),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
