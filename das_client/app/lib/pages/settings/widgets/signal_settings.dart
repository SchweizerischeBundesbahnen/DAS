import 'package:app/i18n/i18n.dart';
import 'package:app/pages/settings/settings_page.dart';
import 'package:app/pages/settings/view_model/model/user_settings_model.dart';
import 'package:app/pages/settings/view_model/user_settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SignalSettings extends StatelessWidget {
  const SignalSettings({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<UserSettingsViewModel>();
    return StreamBuilder<UserSettingsModel>(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final settings = snapshot.data ?? const UserSettingsModel();
        return Column(
          mainAxisSize: .min,
          spacing: SBBSpacing.xxSmall,
          crossAxisAlignment: .start,
          children: [
            SBBListHeader(
              context.l10n.p_settings_page_signal_title,
              style: SBBListHeaderStyle(padding: .only(left: SBBSpacing.medium)),
            ),
            SBBContentBox(
              child: Column(
                children: SBBDivider.divideItems(
                  context: context,
                  items: [
                    SBBSwitchListItem(
                      key: SettingsPage.stationSignalSwitchKey,
                      titleText: context.l10n.p_settings_page_signal_station_setting,
                      value: settings.showStationSignals,
                      onChanged: viewModel.updateShowStationSignals,
                    ),
                    SBBSwitchListItem(
                      key: SettingsPage.ectsConventionalSpeedSignalSwitchKey,
                      titleText: context.l10n.p_settings_page_ects_conventional_speed_signal_setting,
                      value: settings.showEctsConventionalSpeedSignals,
                      onChanged: viewModel.updateShowEctsConventionalSpeedSignals,
                    ),
                    SBBSwitchListItem(
                      key: SettingsPage.ectsExtendedSpeedSignalSwitchKey,
                      titleText: context.l10n.p_settings_page_ects_extended_speed_signal_setting,
                      value: settings.showEctsExtendedSpeedSignals,
                      onChanged: viewModel.updateShowEctsExtendedSpeedSignals,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
