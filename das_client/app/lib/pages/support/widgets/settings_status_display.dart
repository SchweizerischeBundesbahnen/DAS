import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:user_properties/component.dart';

class SettingsStatusDisplay extends StatelessWidget {
  static const _iconSize = 20.0;

  const SettingsStatusDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    final userPropertiesRepository = DI.get<UserPropertiesRepository>();

    return StreamBuilder(
      stream: userPropertiesRepository.model,
      builder: (context, snapshot) {
        final isRequestSuccessful = userPropertiesRepository.lastSettingsRequestSuccessful;
        final lastSuccessTimestamp = userPropertiesRepository.lastSuccessfulSettingsTimestamp;

        return Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          spacing: SBBSpacing.xSmall,
          children: [
            SBBListHeader(
              context.l10n.w_settings_status_title,
              style: SBBListHeaderStyle(padding: .only(left: SBBSpacing.medium)),
            ),
            SBBContentBox(
              padding: const .all(SBBSpacing.medium),
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                spacing: SBBSpacing.xSmall,
                children: [
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
            ),
          ],
        );
      },
    );
  }

  Widget _labelValueItem(String label, Widget valueWidget) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Text(label, style: SBBTextStyles.smallLight),
        valueWidget,
      ],
    );
  }
}
