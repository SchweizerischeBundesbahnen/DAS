import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/app_version_text.dart';
import 'package:app/widgets/device_id_text.dart';
import 'package:app/widgets/mqtt_broker_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DASNavigationDrawer extends StatelessWidget {
  const DASNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final journeyNavigationViewModel = DI.getOrNull<JourneyNavigationViewModel>();
    final isJourneySelected = journeyNavigationViewModel?.modelValue != null;
    final launcher = DI.get<Launcher>();
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
                  route: isJourneySelected ? JourneyRoute() : const JourneySelectionRoute(),
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
                _navigationTile(
                  context,
                  icon: SBBIcons.download_small,
                  title: context.l10n.w_navigation_drawer_preload_title,
                  route: const PreloadRoute(),
                ),
                if (launcher.hasTourSystemConfigured())
                  _drawerTile(
                    context,
                    icon: _inactiveIcon(SBBIcons.link_external_small),
                    title: Text(
                      context.l10n.w_navigation_drawer_tour_system_title,
                      style: sbbTextStyle.lightStyle.medium,
                    ),
                    onTap: () => launcher.launchTourSystem(),
                  ),
              ],
            ),
          ),
          _footer(context),
        ],
      ),
    );
  }

  Widget _navigationTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required PageRouteInfo route,
  }) {
    final bool isActiveRoute = context.router.isRouteActive(route.routeName);

    return _drawerTile(
      context,
      icon: isActiveRoute ? _activeIcon(icon) : _inactiveIcon(icon),
      title: Text(title, style: isActiveRoute ? sbbTextStyle.boldStyle.medium : sbbTextStyle.lightStyle.medium),
      onTap: () {
        Navigator.pop(context);
        context.router.replace(route);
      },
    );
  }

  Widget _drawerTile(
    BuildContext context, {
    required Widget icon,
    required Widget title,
    required GestureTapCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: title,
      onTap: onTap,
    );
  }
}

Widget _activeIcon(IconData icon) {
  return CircleAvatar(
    backgroundColor: SBBColors.black,
    child: Icon(icon),
  );
}

Widget _inactiveIcon(IconData icon) {
  return Padding(
    padding: const .fromLTRB(SBBSpacing.xSmall, 0, SBBSpacing.xSmall, 0),
    child: Icon(icon),
  );
}

Widget _footer(BuildContext context) {
  final textColor = ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite);
  return Align(
    alignment: .bottomCenter,
    child: Padding(
      padding: .all(SBBSpacing.medium),
      child: Column(
        crossAxisAlignment: .start,
        spacing: SBBSpacing.xSmall,
        children: [
          AppVersionText(color: textColor),
          DeviceIdText(color: textColor),
          MqttBrokerText(color: textColor),
        ],
      ),
    ),
  );
}
