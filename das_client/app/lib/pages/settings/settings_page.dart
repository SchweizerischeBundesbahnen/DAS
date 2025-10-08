import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/util/user_settings.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  static const Key decisiveGradientSwitchKey = Key('decisiveGradientSwitch');

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

  SBBHeader _appBar(BuildContext context) => SBBHeader(
    title: context.l10n.c_app_name,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  );

  Widget _body(BuildContext context) {
    return Column(
      spacing: sbbDefaultSpacing,
      children: [
        _settingsHeader(context),
        _settingsBody(context),
      ],
    );
  }

  Widget _settingsHeader(BuildContext context) {
    return SBBHeaderbox(
      title: context.l10n.w_navigation_drawer_settings_title,
      secondaryLabel: context.l10n.p_settings_page_personalize,
    );
  }

  Widget _settingsBody(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing * 0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _settingTitle(context.l10n.p_settings_page_decisive_gradient_title),
          _decisiveGradientSettings(context),
        ],
      ),
    );
  }

  Widget _decisiveGradientSettings(BuildContext context) {
    return SBBGroup(
      padding: const EdgeInsets.only(right: sbbDefaultSpacing),
      child: SBBListItem.custom(
        title: context.l10n.p_settings_page_decisive_gradient_show_setting,
        onPressed: () => _updateSettings(UserSettingKeys.showDecisiveGradient, !_userSettings.showDecisiveGradient),
        isLastElement: true,
        trailingWidget: SBBSwitch(
          key: SettingsPage.decisiveGradientSwitchKey,
          value: _userSettings.showDecisiveGradient,
          onChanged: (value) => _updateSettings(UserSettingKeys.showDecisiveGradient, value),
        ),
      ),
    );
  }

  Widget _settingTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: sbbDefaultSpacing).copyWith(bottom: sbbDefaultSpacing * 0.5),
      child: Text(title, style: DASTextStyles.smallLight),
    );
  }

  void _updateSettings<T>(UserSettingKeys key, T value) async {
    await _userSettings.setUserSetting(key, value);
    setState(() {});
  }
}
