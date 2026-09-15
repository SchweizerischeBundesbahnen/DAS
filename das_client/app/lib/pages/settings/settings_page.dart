import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/nav/das_navigation_drawer.dart';
import 'package:app/pages/settings/view_model/user_settings_view_model.dart';
import 'package:app/pages/settings/widgets/company_setting.dart';
import 'package:app/pages/settings/widgets/decisive_gradient_setting.dart';
import 'package:app/pages/settings/widgets/signal_settings.dart';
import 'package:app/pages/settings/widgets/user_tour_system_selection.dart';
import 'package:app/widgets/user_header_box_preferred_size.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

@RoutePage()
class SettingsPage extends StatelessWidget implements AutoRouteWrapper {
  static const Key decisiveGradientSwitchKey = Key('decisiveGradientSwitch');
  static const Key stationSignalSwitchKey = Key('stationSignalSwitch');
  static const Key ectsConventionalSpeedSignalSwitchKey = Key('ectsConventionalSpeedSignalSwitch');
  static const Key ectsExtendedSpeedSignalSwitchKey = Key('ectsExtendedSpeedSignalSwitch');

  const SettingsPage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return Provider<UserSettingsViewModel>(
      create: (_) => UserSettingsViewModel(userSettings: DI.get(), externalLinksRepository: DI.get()),
      dispose: (_, vm) => vm.dispose(),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _body(context),
      drawer: const DASNavigationDrawer(),
    );
  }

  SBBHeaderSmall _appBar(BuildContext context) => SBBHeaderSmall(
    titleText: context.l10n.p_settings_page_title,
    actions: const [], // removes SBB logo
    bottom: UserHeaderBoxPreferredSize(textScaler: MediaQuery.textScalerOf(context)),
  );

  Widget _body(BuildContext context) {
    return SingleChildScrollView(
      padding: const .symmetric(horizontal: SBBSpacing.xSmall),
      child: Padding(
        padding: const .only(top: SBBSpacing.medium),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          spacing: SBBSpacing.medium,
          children: const [
            CompanySetting(),
            TourSystemSetting(),
            DecisiveGradientSetting(),
            SignalSettings(),
          ],
        ),
      ),
    );
  }
}
