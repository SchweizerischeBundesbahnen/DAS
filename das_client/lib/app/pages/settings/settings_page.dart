import 'package:auto_route/auto_route.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/nav/das_navigation_drawer.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

@RoutePage()
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
    return Center(child: Text(context.l10n.w_navigation_drawer_settings_title));
  }
}
