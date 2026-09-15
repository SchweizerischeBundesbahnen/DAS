import 'package:app/i18n/i18n.dart';
import 'package:app/pages/settings/view_model/model/user_settings_model.dart';
import 'package:app/pages/settings/view_model/user_settings_view_model.dart';
import 'package:app/widgets/company_selection/widgets/select_company_input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class CompanySetting extends StatelessWidget {
  const CompanySetting({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<UserSettingsViewModel>();
    return StreamBuilder<UserSettingsModel>(
      stream: viewModel.model,
      initialData: viewModel.modelValue,
      builder: (context, snapshot) {
        final settings = snapshot.data ?? const UserSettingsModel();
        return Column(
          spacing: SBBSpacing.xxSmall,
          crossAxisAlignment: .start,
          children: [
            SBBListHeader(
              context.l10n.p_train_selection_company_description,
              style: SBBListHeaderStyle(padding: .only(left: SBBSpacing.medium)),
            ),
            SBBContentBox(
              child: SelectCompanyInput(
                selectedCompanyCodes: settings.companyCodes,
                updateCompanies: viewModel.updateCompanies,
                isModalVersion: true,
                allowMultiSelect: true,
              ),
            ),
          ],
        );
      },
    );
  }
}
