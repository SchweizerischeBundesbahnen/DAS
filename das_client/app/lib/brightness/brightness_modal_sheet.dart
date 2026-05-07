import 'package:app/brightness/brightness_manager.dart';
import 'package:app/di/di.dart';
import 'package:app/i18n/i18n.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrightnessModalSheet extends StatelessWidget {
  const BrightnessModalSheet({super.key});

  static Future<void> openIfNeeded(BuildContext context) async {
    final brightnessManager = DI.get<BrightnessManager>();
    final hasPermission = await brightnessManager.hasWriteSettingsPermission();

    if (!hasPermission && context.mounted) {
      await showSBBBottomSheet(
        context: context,
        titleText: context.l10n.w_modal_sheet_permissions_title,
        body: const BrightnessModalSheet(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const .all(SBBSpacing.medium),
      child: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisSize: .min,
      children: [
        Text(
          context.l10n.w_modal_sheet_permission_brightness,
          style: sbbTextStyle.romanStyle.medium,
        ),
        SizedBox(height: SBBSpacing.xLarge),
        SBBPrimaryButton(
          labelText: context.l10n.w_modal_sheet_button_grant_permission,
          onPressed: () async {
            final brightnessManager = DI.get<BrightnessManager>();
            await brightnessManager.requestWriteSettings();
          },
        ),
      ],
    );
  }
}
