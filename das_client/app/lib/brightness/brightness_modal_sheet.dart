import 'package:app/i18n/i18n.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrightnessModalSheet extends StatelessWidget {
  const BrightnessModalSheet({super.key});

  static Future<void> openIfNeeded(BuildContext context) async {
    final brightnessManager = DI.get<BrightnessManager>();
    final hasPermission = await brightnessManager.hasWriteSettingsPermission();

    if (!hasPermission && context.mounted) {
      await showSBBModalSheet(
        context: context,
        title: context.l10n.w_modal_sheet_permissions_title,
        child: const BrightnessModalSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(sbbDefaultSpacing),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.l10n.w_modal_sheet_permission_brightness,
          style: DASTextStyles.mediumRoman,
        ),
        SizedBox(height: sbbDefaultSpacing * 2),
        SBBPrimaryButton(
          label: context.l10n.w_modal_sheet_button_grant_permission,
          onPressed: () async {
            final brightnessManager = DI.get<BrightnessManager>();
            await brightnessManager.requestWriteSettings();
          },
        ),
      ],
    );
  }
}
