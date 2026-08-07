import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:external_links/component.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class UserRuSelection extends StatefulWidget {
  const UserRuSelection({super.key});

  @override
  State<UserRuSelection> createState() => _UserRuSelectionState();
}

class _UserRuSelectionState extends State<UserRuSelection> {
  final _userSettings = DI.get<LocalKeyValueStore>();
  final _externalLinksRepo = DI.get<ExternalLinksRepository>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .symmetric(horizontal: SBBSpacing.xSmall),
      child: Column(
        spacing: SBBSpacing.xSmall,
        crossAxisAlignment: .start,
        children: [
          SBBListHeader(
            context.l10n.p_train_selection_ru_description,
            style: SBBListHeaderStyle(padding: .symmetric(horizontal: SBBSpacing.medium)),
          ),
          SBBContentBox(
            child: SelectRailwayUndertakingInput(
              selectedCompanyCodes: _userSettings.companyCodes,
              updateCompanies: (selected) async {
                await _userSettings.set(.companyCodes, selected.map((it) => it.shortName).toList());
                _externalLinksRepo.reloadExternalLinksByCompanies(selected.map((it) => it.code).toList());
                setState(() {});
              },
              isModalVersion: true,
              allowMultiSelect: true,
            ),
          ),
        ],
      ),
    );
  }
}
