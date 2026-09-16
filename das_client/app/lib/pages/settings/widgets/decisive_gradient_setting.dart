import 'package:app/i18n/i18n.dart';
import 'package:app/pages/settings/settings_page.dart';
import 'package:app/pages/settings/view_model/model/user_settings_model.dart';
import 'package:app/pages/settings/view_model/user_settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class DecisiveGradientSetting extends StatelessWidget {
  const DecisiveGradientSetting({super.key});

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
              context.l10n.p_settings_page_decisive_gradient_title,
              style: SBBListHeaderStyle(padding: .only(left: SBBSpacing.medium)),
            ),
            SBBSwitchListItemBoxed(
              key: SettingsPage.decisiveGradientSwitchKey,
              titleText: context.l10n.p_settings_page_decisive_gradient_show_setting,
              value: settings.showDecisiveGradient,
              onChanged: viewModel.updateShowDecisiveGradient,
            ),
          ],
        );
      },
    );
  }
}
