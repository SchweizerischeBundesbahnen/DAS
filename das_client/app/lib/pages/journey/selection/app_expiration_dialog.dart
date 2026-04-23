import 'package:app/i18n/i18n.dart';
import 'package:app/pages/journey/view_model/model/app_expiration_model.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/util/format.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class AppExpirationDialog extends StatelessWidget {
  static const double _maxWidth = 500;

  const AppExpirationDialog({required this.model, super.key});

  final AppExpirationModel model;

  @override
  Widget build(BuildContext context) {
    assert(model is! Valid);

    final isExpired = model is Expired;
    return Dialog(
      alignment: .topLeft,
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
                Expanded(
                  child: Text(
                    isExpired ? context.l10n.w_app_expired_dialog_title : context.l10n.w_app_expires_soon_dialog_title,
                    style: sbbTextStyle.large,
                  ),
                ),
                if (!isExpired)
                  SBBIconButtonSmall(
                    icon: SBBIcons.cross_small,
                    onPressed: () => context.router.pop<bool>(false),
                  ),
              ],
            ),
            SBBMessage(
              title: isExpired
                  ? context.l10n.w_app_expired_dialog_body_title(model.currentAppVersion)
                  : context.l10n.w_app_expires_soon_dialog_body_title(
                      model.currentAppVersion,
                      Format.date((model as ExpirySoon).expiryDate),
                    ),
              description: isExpired
                  ? context.l10n.w_app_expired_dialog_body_subTitle
                  : context.l10n.w_app_expires_soon_dialog_body_subTitle,
              illustration: .Display,
            ),
          ],
        ),
      ),
    );
  }
}

Future<dynamic> showAppExpiresSoonDialog(ExpirySoon model, BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return AppExpirationDialog(model: model);
    },
  );
}

Future<dynamic> showAppExpiredDialog(Expired model, BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return AppExpirationDialog(model: model);
    },
  );
}
