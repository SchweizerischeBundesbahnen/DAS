import 'package:app/di/di.dart';
import 'package:auth/component.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class UserHeaderBox extends StatelessWidget {
  const UserHeaderBox({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DI.get<Authenticator>().user(),
      builder: (context, asyncSnapshot) {
        final headerBoxStyle = Theme.of(context).sbbHeaderBoxTheme.style;

        return SBBHeaderBox(
          title: Row(
            spacing: SBBSpacing.small,
            children: [
              const Icon(SBBIcons.user_small),
              Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  Text(asyncSnapshot.data?.displayName ?? '', style: headerBoxStyle?.titleTextStyle),
                  Text(
                    asyncSnapshot.data?.userId ?? '',
                    style: headerBoxStyle?.subtitleTextStyle?.copyWith(color: headerBoxStyle.subtitleForegroundColor),
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
