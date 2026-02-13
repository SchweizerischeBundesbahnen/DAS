import 'package:app/i18n/i18n.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/pages/profile/widgets/user_header_box.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
      drawer: const DASNavigationDrawer(),
    );
  }

  SBBHeader _appBar(BuildContext context) {
    return SBBHeader(
      title: context.l10n.w_navigation_drawer_profile_title,
      systemOverlayStyle: .light,
    );
  }

  Widget _body(BuildContext context) {
    return UserHeaderBox();
  }
}
