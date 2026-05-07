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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SBBSpacing.medium),
            child: Text(context.l10n.w_user_tour_system_selection_label, style: sbbTextStyle.lightStyle.small),
          ),
          SBBContentBox(
            child: SBBDropdown<TourSystem?>(
              triggerDecoration: SBBInputDecoration(
                labelText: context.l10n.w_user_tour_system_selection_title,
                placeholderText: context.l10n.w_user_tour_system_selection_label,
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
