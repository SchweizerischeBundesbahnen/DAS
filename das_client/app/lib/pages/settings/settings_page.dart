import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/pages/settings/user_settings.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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
    systemOverlayStyle: .light,
    actions: [Container()],
  );

  Widget _body(BuildContext context) {
    return Column(
      spacing: SBBSpacing.medium,
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
      padding: const .symmetric(horizontal: SBBSpacing.xSmall),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          _settingTitle(context.l10n.p_settings_page_decisive_gradient_title),
          _decisiveGradientSettings(context),
        ],
      ),
    );
  }

  Widget _decisiveGradientSettings(BuildContext context) {
    return SBBContentBox(
      padding: const .only(right: SBBSpacing.medium),
      child: SBBListItem.custom(
        title: context.l10n.p_settings_page_decisive_gradient_show_setting,
        onPressed: () => _updateSettings(.showDecisiveGradient, !_userSettings.showDecisiveGradient),
        isLastElement: true,
        trailingWidget: SBBSwitch(
          key: SettingsPage.decisiveGradientSwitchKey,
          value: _userSettings.showDecisiveGradient,
          onChanged: (value) => _updateSettings(.showDecisiveGradient, value),
        ),
      ),
    );
  }

  Widget _settingTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.medium).copyWith(bottom: SBBSpacing.xSmall),
      child: Text(title, style: sbbTextStyle.lightStyle.small),
    );
  }

  void _updateSettings<T>(UserSettingKeys key, T value) async {
    await _userSettings.set(key, value);
    setState(() {});
  }
}
