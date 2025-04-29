import 'package:das_client/app/i18n/i18n.dart';
import 'package:das_client/app/widgets/das_text_styles.dart';
import 'package:das_client/brightness/brightness_manager_impl.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:screen_brightness/screen_brightness.dart';

class PermissionRequestContent extends StatelessWidget {
  const PermissionRequestContent({super.key});

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
    final brightnessManager = BrightnessManagerImpl(ScreenBrightness());

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
            await brightnessManager.requestWriteSettings();
          },
        ),
      ],
    );
  }
}
