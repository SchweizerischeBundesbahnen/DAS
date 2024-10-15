import 'package:auto_route/auto_route.dart';
import 'package:das_client/i18n/src/build_context_x.dart';
import 'package:das_client/nav/app_router.dart';
import 'package:das_client/widgets/app_version_text.dart';
import 'package:das_client/widgets/device_id_text.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class DASNavigationDrawer extends StatefulWidget {
  const DASNavigationDrawer({super.key});

  @override
  State<DASNavigationDrawer> createState() => _DASNavigationDrawerState();
}

class _DASNavigationDrawerState extends State<DASNavigationDrawer> {
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
                  route: const FahrtRoute(),
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
                _navigationTile(context,
                    icon: SBBIcons.user_small,
                    title: context.l10n.w_navigation_drawer_profile_title,
                    route: const ProfileRoute()),
              ],
            ),
          ),
          _versionFooter(),
        ],
      ),
    );
  }

  Widget _navigationTile(BuildContext context,
      {required IconData icon, required String title, required PageRouteInfo route, bool active = true}) {
    bool isActiveRoute = context.router.isRouteActive(route.routeName);

    return ListTile(
      leading: isActiveRoute ? _activeIcon(icon) : _inactiveIcon(icon),
      title: Text(title, style: isActiveRoute ? SBBTextStyles.mediumBold : SBBTextStyles.mediumLight),
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
