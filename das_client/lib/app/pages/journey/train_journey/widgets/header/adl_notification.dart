import 'package:das_client/app/i18n/i18n.dart';
import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class ADLNotification extends StatelessWidget {
  const ADLNotification({super.key, required this.message, this.margin});

  final String message;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final fontColor = isDarkTheme ? SBBColors.charcoal : SBBColors.white;
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: isDarkTheme ? SBBColors.cloud : SBBColors.charcoal,
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14.0).copyWith(left: sbbDefaultSpacing, right: 4.0),
      child: Row(
        children: [
          Icon(SBBIcons.circle_information_small, color: fontColor),
          const SizedBox(width: sbbDefaultSpacing * 0.5),
          Text(
            '${context.l10n.w_adl_notification_title}: $message',
            style: SBBTextStyles.mediumBold.copyWith(color: fontColor),
          ),
        ],
      ),
    );
  }
}
