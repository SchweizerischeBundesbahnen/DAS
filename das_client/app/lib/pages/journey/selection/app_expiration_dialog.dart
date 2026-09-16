import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/view_model/model/app_expiration_model.dart';
import 'package:app/util/format.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class AppExpirationDialog extends StatelessWidget {
  static const double _maxWidth = 500;

  const AppExpirationDialog({required this.model, super.key});

  final AppExpirationModel model;

  @override
  Widget build(BuildContext context) {
    if (model is Valid) return SizedBox.shrink();

    final isExpired = model is Expired;
    return SBBPopup(
      style: SBBPopupStyle(
        alignment: .topLeft,
        constraints: const BoxConstraints(maxWidth: _maxWidth),
      ),
      titleText: isExpired ? context.l10n.w_app_expired_dialog_title : context.l10n.w_app_expires_soon_dialog_title,
      showCloseButton: !isExpired,
      body: _body(isExpired, context),
    );
  }

  Widget _body(bool isExpired, BuildContext context) {
    return SBBMessage(
      titleText: isExpired
          ? context.l10n.w_app_expired_dialog_body_title(model.currentAppVersion)
          : context.l10n.w_app_expires_soon_dialog_body_title(
              model.currentAppVersion,
              Format.date((model as ExpirySoon).expiryDate),
            ),
      subtitleText: isExpired
          ? context.l10n.w_app_expired_dialog_body_subTitle
          : context.l10n.w_app_expires_soon_dialog_body_subTitle,
      illustration: SBBIllustration.display(),
    );
  }
}

Future<dynamic> showAppExpiresSoonDialog(ExpirySoon model, BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => AppExpirationDialog(model: model),
  );
}

Future<dynamic> showAppExpiredDialog(Expired model, BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AppExpirationDialog(model: model),
  );
}
