import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/launcher/launcher.dart';
import 'package:app/nav/app_router.dart';
import 'package:app/nav/view_model/model/navigation_drawer_weather_model.dart';
import 'package:app/nav/view_model/navigation_drawer_weather_view_model.dart';
import 'package:app/pages/journey/view_model/journey_navigation_view_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/app_version_text.dart';
import 'package:app/widgets/device_id_text.dart';
import 'package:app/widgets/mqtt_broker_text.dart';
import 'package:app/widgets/weather_text.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:weather/component.dart';

class DASNavigationDrawer extends StatelessWidget {
  const DASNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final journeyNavigationViewModel = DI.getOrNull<JourneyNavigationViewModel>();
    final isJourneySelected = journeyNavigationViewModel?.modelValue != null;
    final weatherViewModel = DI.getOrNull<NavigationDrawerWeatherViewModel>();
    final launcher = DI.get<Launcher>();
    return Drawer(
      // TODO: remove when set by SBB again
      backgroundColor: Theme.of(context).sbbBaseStyle.colorScheme.backgroundContent,
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
                  route: isJourneySelected ? JourneyRoute() : JourneySelectionRoute(),
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
                  ListTile(
                    leading: _inactiveIcon(SBBIcons.link_external_small),
                    title: Text(
                      context.l10n.w_navigation_drawer_tour_system_title,
                      style: sbbTextStyle.lightStyle.medium,
                    ),
                    onTap: () => launcher.launchTourSystem(),
                  ),
                if (weatherViewModel != null) _weatherTile(context, weatherViewModel),
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

    return ListTile(
      leading: isActiveRoute ? _activeIcon(icon) : _inactiveIcon(icon),
      title: Text(title, style: isActiveRoute ? sbbTextStyle.boldStyle.medium : sbbTextStyle.lightStyle.medium),
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
      padding: const .fromLTRB(SBBSpacing.xSmall, 0, SBBSpacing.xSmall, 0),
      child: Icon(icon),
    );
  }

  Widget _footer(BuildContext context) {
    final textColor = ThemeUtil.getColor(context, SBBColors.granite, SBBColors.graphite);
    return Align(
      alignment: .bottomLeft,
      child: Padding(
        padding: .all(SBBSpacing.medium),
        child: Column(
          crossAxisAlignment: .start,
          spacing: SBBSpacing.xSmall,
          children: [
            WeatherText(color: textColor),
            AppVersionText(color: textColor),
            DeviceIdText(color: textColor),
            MqttBrokerText(color: textColor),
          ],
        ),
      ),
    );
  }

  Widget _weatherTile(BuildContext context, NavigationDrawerWeatherViewModel viewModel) {
    return ListTile(
      leading: _inactiveIcon(_iconForCondition(null)),
      title: Text(
        context.l10n.w_navigation_drawer_weather_title,
        style: sbbTextStyle.lightStyle.medium,
      ),
      subtitle: StreamBuilder<NavigationDrawerWeatherModel>(
        stream: viewModel.model,
        initialData: viewModel.modelValue,
        builder: (context, snap) {
          final model = snap.requireData;
          final weatherText = switch (model) {
            NavigationDrawerWeatherLoading() => context.l10n.w_navigation_drawer_weather_loading,
            NavigationDrawerWeatherError() => context.l10n.w_navigation_drawer_weather_unavailable,
            NavigationDrawerWeatherData() =>
              '${model.temperatureCelsius.round()}°C - ${_conditionLabel(context, model.condition)}',
          };

          return Row(
            children: [
              Icon(_iconForCondition(model)),
              const SizedBox(width: SBBSpacing.xSmall),
              Expanded(child: Text(weatherText)),
            ],
          );
        },
      ),
      onTap: () => viewModel.refresh(),
    );
  }

  IconData _iconForCondition(NavigationDrawerWeatherModel? model) {
    if (model case NavigationDrawerWeatherData(condition: final condition)) {
      return switch (condition) {
        WeatherCondition.clear => Icons.wb_sunny_outlined,
        WeatherCondition.partlyCloudy || WeatherCondition.overcast => Icons.cloud_outlined,
        WeatherCondition.fog => Icons.dehaze,
        WeatherCondition.drizzle || WeatherCondition.rain => Icons.water_drop_outlined,
        WeatherCondition.snow => Icons.ac_unit,
        WeatherCondition.thunderstorm => Icons.thunderstorm_outlined,
        WeatherCondition.unknown => Icons.thermostat_outlined,
      };
    }

    return Icons.thermostat_outlined;
  }

  String _conditionLabel(BuildContext context, WeatherCondition condition) {
    return switch (condition) {
      WeatherCondition.clear => context.l10n.w_navigation_drawer_weather_condition_clear,
      WeatherCondition.partlyCloudy => context.l10n.w_navigation_drawer_weather_condition_partly_cloudy,
      WeatherCondition.overcast => context.l10n.w_navigation_drawer_weather_condition_overcast,
      WeatherCondition.fog => context.l10n.w_navigation_drawer_weather_condition_fog,
      WeatherCondition.drizzle => context.l10n.w_navigation_drawer_weather_condition_drizzle,
      WeatherCondition.rain => context.l10n.w_navigation_drawer_weather_condition_rain,
      WeatherCondition.snow => context.l10n.w_navigation_drawer_weather_condition_snow,
      WeatherCondition.thunderstorm => context.l10n.w_navigation_drawer_weather_condition_thunderstorm,
      WeatherCondition.unknown => context.l10n.w_navigation_drawer_weather_condition_unknown,
    };
  }
}
