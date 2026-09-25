import 'package:app/i18n/src/build_context_x.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class LogoutDialog extends StatelessWidget {
  static const double _maxWidth = 430;

  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return SBBPopup(
      style: SBBPopupStyle(
        alignment: .topRight,
        constraints: BoxConstraints(maxWidth: _maxWidth),
      ),
      titleText: context.l10n.w_logout_dialog_title,
      body: _body(context),
    );
  }

  Widget _body(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        Text(context.l10n.w_logout_dialog_subTitle, style: sbbTextStyle.small),
        SizedBox(height: SBBSpacing.large),
        SBBSecondaryButton(
          labelText: context.l10n.w_logout_dialog_cancel_button_labelText,
          onPressed: () => context.router.pop<bool>(false),
        ),
        SizedBox(height: SBBSpacing.xSmall),
        SBBPrimaryButton(
          labelText: context.l10n.w_logout_dialog_confirm_button_labelText,
          onPressed: () => context.router.pop<bool>(true),
        ),
      ],
    );
  }
}
