import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/brightness/brightness_manager.dart';
import 'package:das_client/di.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class BrightnessModalSheet extends StatelessWidget {
  const BrightnessModalSheet({super.key});

  static Future<void> openBrightnessModalSheet(BuildContext context) async {
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(sbbDefaultSpacing),
        child: SafeArea(
          child: _body(context),
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          context.l10n.w_modal_sheet_all_permissions,
          textAlign: TextAlign.center,
          style: DASTextStyles.largeRoman,
        ),
        SizedBox(height: sbbDefaultSpacing * 2),
        Text(
          context.l10n.w_modal_sheet_permission_brightness,
          style: DASTextStyles.mediumRoman,
        ),
        const Spacer(),
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
