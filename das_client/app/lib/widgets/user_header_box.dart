import 'package:app/di/di.dart';
import 'package:auth/component.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class UserHeaderBoxPreferredSize extends StatelessWidget implements PreferredSizeWidget {
  const UserHeaderBoxPreferredSize({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: DI.get<Authenticator>().user(),
      builder: (context, asyncSnapshot) {
        final headerBoxStyle = Theme.of(context).sbbHeaderBoxTheme.style;

        return SBBHeaderBoxPreferredSize(
          titleText: asyncSnapshot.data?.displayName ?? '',
          subtitleText: asyncSnapshot.data?.userId ?? '',
          leadingIconData: SBBIcons.user_small,
          textScaler: MediaQuery.textScalerOf(context),
        );
      },
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => throw UnimplementedError();
}
