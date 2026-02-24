import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/provider/user_settings.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class UserRuSelection extends StatefulWidget {
  const UserRuSelection({super.key});

  @override
  State<UserRuSelection> createState() => _UserRuSelectionState();
}

class _UserRuSelectionState extends State<UserRuSelection> {
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
            child: Text(context.l10n.p_train_selection_ru_description, style: sbbTextStyle.lightStyle.small),
          ),
          SBBContentBox(
            child: SelectRailwayUndertakingInput(
              selectedRailwayUndertakings: _userSettings.railwayUndertakings,
              updateRailwayUndertaking: (selected) async {
                await _userSettings.set(.railwayUndertakings, selected.map((it) => it.name).toList());
                setState(() {});
              },
              isModalVersion: true,
              allowMultiSelect: true,
              isLastElement: true,
            ),
          ),
        ],
      ),
    );
  }
}
