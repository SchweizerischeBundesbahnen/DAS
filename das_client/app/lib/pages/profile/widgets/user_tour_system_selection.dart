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
            child: SBBSelect<TourSystem?>(
              hint: context.l10n.w_user_tour_system_selection_label,
              title: context.l10n.w_user_tour_system_selection_title,
              value: _userSettings.tourSystem,
              items: TourSystem.values.map((it) {
                return SelectMenuItem(value: it, label: it.localizedName(context));
              }).toList(),
              onChanged: (selected) {
                _userSettings.set(.tourSystem, selected?.name);
                setState(() {});
              },
              isLastElement: true,
            ),
          ),
        ],
      ),
    );
  }
}
