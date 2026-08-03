import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:app/widgets/railway_undertaking/widgets/select_railway_undertaking_input.dart';
import 'package:core_data/component.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:settings/component.dart';

class RuFeatureStatusDisplay extends StatefulWidget {
  const RuFeatureStatusDisplay({super.key});

  @override
  State<RuFeatureStatusDisplay> createState() => _RuFeatureStatusDisplayState();
}

class _RuFeatureStatusDisplayState extends State<RuFeatureStatusDisplay> {
  static const _iconSize = 20.0;
  late final SettingsRepository _settingsRepository;
  late final LocalKeyValueStore _localStore;

  RailwayUndertaking? _selectedRu;

  @override
  void initState() {
    super.initState();
    _settingsRepository = DI.get<SettingsRepository>();
    _localStore = DI.get<LocalKeyValueStore>();
    _selectedRu = _localStore.lastUsedRailwayUndertaking;
  }

  @override
  Widget build(BuildContext context) {
    return SBBContentBox(
      padding: const EdgeInsets.all(SBBSpacing.small),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: SBBSpacing.xSmall,
        children: [
          Text(context.l10n.w_ru_feature_status_title, style: SBBTextStyles.mediumBold),
          _ruDropdown(context),
          ...RuFeatureKeys.values.map((key) => _featureRow(context, key)),
        ],
      ),
    );
  }

  Widget _ruDropdown(BuildContext context) {
    return SelectRailwayUndertakingInput(
      selectedRailwayUndertakings: _selectedRu != null ? [_selectedRu!] : [],
      isModalVersion: true,
      borderType: .standalone,
      updateRailwayUndertaking: (selected) {
        final ru = selected.firstOrNull;
        if (ru != null) {
          setState(() => _selectedRu = ru);
        }
      },
    );
  }

  Widget _featureRow(BuildContext context, RuFeatureKeys key) {
    final companyCode = _selectedRu?.companyCode;
    if (companyCode == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: _settingsRepository.isRuFeatureEnabled(key, companyCode),
      builder: (context, asyncSnapshot) {
        final isEnabled = asyncSnapshot.data;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key.displayText(context), style: SBBTextStyles.smallLight),
            isEnabled == null
                ? Text('-', style: SBBTextStyles.smallLight)
                : Icon(
                    isEnabled ? Icons.check_circle : Icons.cancel,
                    color: isEnabled ? SBBColors.green : SBBColors.red,
                    size: _iconSize,
                  ),
          ],
        );
      },
    );
  }
}

extension _RuFeatureKeysExtension on RuFeatureKeys {
  String displayText(BuildContext context) => switch (this) {
    .warnapp => context.l10n.w_ru_feature_status_warnapp,
    .customerOrientedDeparture => context.l10n.w_ru_feature_status_customer_oriented_departure,
    .departureProcess => context.l10n.w_ru_feature_status_departure_process,
    .plannedTimeDeviation => context.l10n.w_ru_feature_status_planned_time_deviation,
  };
}
