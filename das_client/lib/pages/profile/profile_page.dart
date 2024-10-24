import 'package:auto_route/auto_route.dart';
import 'package:das_client/i18n/src/build_context_x.dart';
import 'package:das_client/nav/das_navigation_drawer.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

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
      title: context.l10n.c_app_name,
    );
  }

  Widget _body(BuildContext context) {
    return Center(child: Text(context.l10n.w_navigation_drawer_profile_title));
  }
}
