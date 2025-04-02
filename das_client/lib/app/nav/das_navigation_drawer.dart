import 'package:auto_route/auto_route.dart';
import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/nav/app_router.dart';
import 'package:das_client/app/widgets/app_version_text.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/app/widgets/device_id_text.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

class DASNavigationDrawer extends StatelessWidget {
  const DASNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              shrinkWrap: true,
              children: [
                _navigationTile(
                  context,
                  icon: SBBIcons.route_circle_start_small,
                  title: context.l10n.w_navigation_drawer_fahrtinfo_title,
                  route: const JourneyRoute(),
                ),
                _navigationTile(
                  context,
                  icon: SBBIcons.link_external_small,
                  title: context.l10n.w_navigation_drawer_links_title,
                  route: const LinksRoute(),
                ),
                _navigationTile(
                  context,
                  icon: SBBIcons.gears_small,
                  title: context.l10n.w_navigation_drawer_settings_title,
                  route: const SettingsRoute(),
                ),
                _navigationTile(
                  context,
                  icon: SBBIcons.user_small,
                  title: context.l10n.w_navigation_drawer_profile_title,
                  route: const ProfileRoute(),
                ),
              ],
            ),
          ),
          _versionFooter(),
        ],
      ),
    );
  }

  Widget _navigationTile(BuildContext context,
      {required IconData icon, required String title, required PageRouteInfo route}) {
    final bool isActiveRoute = context.router.isRouteActive(route.routeName);

    return ListTile(
      leading: isActiveRoute ? _activeIcon(icon) : _inactiveIcon(icon),
      title: Text(title, style: isActiveRoute ? DASTextStyles.mediumBold : DASTextStyles.mediumLight),
      onTap: () {
        Navigator.pop(context);
        context.router.replace(route);
      },
    );
  }

  Widget _activeIcon(IconData icon) {
    return CircleAvatar(
      backgroundColor: SBBColors.black,
      child: Icon(icon),
    );
  }

  Widget _inactiveIcon(IconData icon) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(sbbDefaultSpacing / 2, 0, sbbDefaultSpacing / 2, 0),
      child: Icon(icon),
    );
  }

  Widget _versionFooter() {
    return const Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.all(sbbDefaultSpacing),
        child: Column(
          children: [
            AppVersionText(
              color: SBBColors.granite,
            ),
            DeviceIdText(
              color: SBBColors.granite,
            )
          ],
        ),
      ),
    );
  }
}
