import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/provider/user_settings.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  static const Key decisiveGradientSwitchKey = Key('decisiveGradientSwitch');
  static const Key stationSignalSwitchKey = Key('stationSignalSwitch');

  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _userSettings = DI.get<UserSettings>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
      drawer: const DASNavigationDrawer(),
    );
  }

  SBBHeaderSmall _appBar(BuildContext context) => SBBHeaderSmall(
    titleText: context.l10n.c_app_name,
    actions: const [], // removes SBB logo
    bottom: SBBHeaderBoxPreferredSize(
      titleText: context.l10n.w_navigation_drawer_settings_title,
      subtitleText: context.l10n.p_settings_page_personalize,
      textScaler: MediaQuery.textScalerOf(context),
    ),
  );

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      padding: const .symmetric(horizontal: SBBSpacing.xSmall),
      child: Padding(
        padding: const .only(top: SBBSpacing.medium),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            _settingTitle(context.l10n.p_settings_page_decisive_gradient_title, isFirstElement: true),
            _decisiveGradientSettings(context),
            _settingTitle(context.l10n.p_settings_page_signal_title),
            _signalSettings(context),
          ],
        ),
      ),
    );
  }

  Widget _decisiveGradientSettings(BuildContext context) {
    return SBBSwitchListItemBoxed(
      key: SettingsPage.decisiveGradientSwitchKey,
      titleText: context.l10n.p_settings_page_decisive_gradient_show_setting,
      value: _userSettings.showDecisiveGradient,
      onChanged: (value) => _updateSettings(.showDecisiveGradient, value),
    );
  }

  Widget _signalSettings(BuildContext context) {
    return SBBSwitchListItemBoxed(
      key: SettingsPage.stationSignalSwitchKey,
      titleText: context.l10n.p_settings_page_signal_station_setting,
      value: _userSettings.showStationSignals,
      onChanged: (value) => _updateSettings(.showStationSignals, value),
    );
  }

  Widget _settingTitle(String title, {bool isFirstElement = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SBBSpacing.medium,
      ).copyWith(bottom: SBBSpacing.xSmall, top: isFirstElement ? 0 : SBBSpacing.medium),
      child: Text(title, style: sbbTextStyle.lightStyle.small),
    );
  }

  void _updateSettings<T>(UserSettingKeys key, T value) async {
    await _userSettings.set(key, value);
    setState(() {});
  }
}
