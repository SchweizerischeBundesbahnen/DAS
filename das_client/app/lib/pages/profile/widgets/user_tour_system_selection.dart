import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/model/tour_system.dart';
import 'package:app/provider/user_settings.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class UserTourSystemSelection extends StatefulWidget {
  const UserTourSystemSelection({super.key});

  @override
  State<UserTourSystemSelection> createState() => _UserTourSystemSelectionState();
}

class _UserTourSystemSelectionState extends State<UserTourSystemSelection> {
  final _userSettings = DI.get<UserSettings>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.xSmall),
      child: Column(
        spacing: SBBSpacing.xSmall,
        crossAxisAlignment: .start,
        children: [
          SBBListHeader(
            context.l10n.w_user_tour_system_selection_label,
            style: SBBListHeaderStyle(padding: .symmetric(horizontal: SBBSpacing.medium)),
          ),
          SBBContentBox(
            child: SBBDropdown<TourSystem?>(
              triggerDecoration: SBBInputDecoration(
                placeholderText: context.l10n.w_user_tour_system_selection_label,
              ),
              sheetConfig: SBBBottomSheetConfig(
                titleText: context.l10n.w_user_tour_system_selection_title,
              ),
              selectedItem: _userSettings.tourSystem,
              items: _tourSystemItems(context),
              onChanged: (selected) {
                _userSettings.set(.tourSystem, selected?.name);
                setState(() {});
              },
            ),
          ),
        ],
      ),
    );
  }

  List<SBBDropdownItem<TourSystem?>> _tourSystemItems(BuildContext context) {
    return TourSystem.values
        .map((it) => SBBDropdownItem<TourSystem?>(value: it, label: it.localizedName(context)))
        .toList()
      ..add(SBBDropdownItem<TourSystem?>(value: null, label: context.l10n.w_user_tour_system_selection_none));
  }
}
