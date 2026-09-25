import 'package:app/i18n/i18n.dart';
import 'package:app/model/tour_system.dart';
import 'package:app/pages/settings/view_model/model/user_settings_model.dart';
import 'package:app/pages/settings/view_model/user_settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class TourSystemSetting extends StatelessWidget {
  const TourSystemSetting({super.key});

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
              context.l10n.w_user_tour_system_selection_label,
              style: SBBListHeaderStyle(padding: .only(left: SBBSpacing.medium)),
            ),
            SBBContentBox(
              child: SBBDropdown<TourSystem?>(
                triggerDecoration: SBBInputDecoration(
                  placeholderText: context.l10n.w_user_tour_system_selection_label,
                ),
                sheetConfig: SBBBottomSheetConfig(
                  titleText: context.l10n.w_user_tour_system_selection_title,
                ),
                selectedItem: settings.tourSystem,
                items: _tourSystemItems(context),
                onChanged: viewModel.updateTourSystem,
              ),
            ),
          ],
        );
      },
    );
  }

  List<SBBDropdownItem<TourSystem?>> _tourSystemItems(BuildContext context) {
    return TourSystem.values
        .map((it) => SBBDropdownItem<TourSystem?>(value: it, label: it.localizedName(context)))
        .toList()
      ..add(SBBDropdownItem<TourSystem?>(value: null, label: context.l10n.w_user_tour_system_selection_none));
  }
}
