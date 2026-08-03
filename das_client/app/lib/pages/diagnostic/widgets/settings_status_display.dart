import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/provider/local_key_value_store.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class SettingsStatusDisplay extends StatelessWidget {
  static const _iconSize = 20.0;

  const SettingsStatusDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final localStore = DI.get<LocalKeyValueStore>();

    return StreamBuilder(
      stream: localStore.model,
      builder: (context, snapshot) {
        final isRequestSuccessful = localStore.lastSettingsRequestSuccessful;
        final lastSuccessTimestamp = localStore.lastSuccessfulSettingsTimestamp;

        return SBBContentBox(
          padding: const EdgeInsets.all(SBBSpacing.small),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: SBBSpacing.xSmall,
            children: [
              Text(context.l10n.w_settings_status_title, style: SBBTextStyles.mediumBold),
              _labelValueItem(
                context.l10n.w_settings_status_last_request_successful,
                isRequestSuccessful
                    ? const Icon(Icons.check_circle, color: SBBColors.green, size: _iconSize)
                    : const Icon(Icons.cancel, color: SBBColors.red, size: _iconSize),
              ),
              _labelValueItem(
                context.l10n.w_settings_status_last_successful_timestamp,
                Text(Format.datetime(lastSuccessTimestamp, '-'), style: SBBTextStyles.smallLight),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _labelValueItem(String label, Widget valueWidget) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: SBBTextStyles.smallLight),
        valueWidget,
      ],
    );
  }
}
