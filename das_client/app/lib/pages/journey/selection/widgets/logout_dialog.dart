import 'package:app/i18n/src/build_context_x.dart';
import 'package:app/theme/theme_util.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class LogoutDialog extends StatelessWidget {
  static const double _maxWidth = 430;

  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      alignment: .topRight,
      child: Container(
        decoration: BoxDecoration(
          color: ThemeUtil.getColor(context, SBBColors.milk, SBBColors.midnight),
          borderRadius: BorderRadius.circular(SBBSpacing.medium),
        ),
        padding: .all(SBBSpacing.medium),
        constraints: BoxConstraints(maxWidth: _maxWidth),
        child: Column(
          crossAxisAlignment: .start,
          mainAxisSize: .min,
          children: [
            Row(
              children: [
                Expanded(child: Text(context.l10n.w_logout_dialog_title, style: sbbTextStyle.large)),
                SBBTertiaryButtonSmall(
                  iconData: SBBIcons.cross_small,
                  onPressed: () => context.router.pop<bool>(false),
                ),
              ],
            ),
            SizedBox(height: SBBSpacing.small),
            Text(context.l10n.w_logout_dialog_subTitle, style: sbbTextStyle.small),
            SizedBox(height: SBBSpacing.large),
            SBBSecondaryButton(
              label: context.l10n.w_logout_dialog_cancel_button_labelText,
              onPressed: () => context.router.pop<bool>(false),
            ),
            SizedBox(height: SBBSpacing.xSmall),
            SBBPrimaryButton(
              label: context.l10n.w_logout_dialog_confirm_button_labelText,
              onPressed: () => context.router.pop<bool>(true),
            ),
          ],
        ),
      ),
    );
  }
}
