import 'package:app/i18n/i18n.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ADLNotification extends StatelessWidget {
  const ADLNotification({required this.message, super.key, this.margin});

  final String message;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final fontColor = ThemeUtil.getFontColor(context);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: fontColor,
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14.0).copyWith(left: sbbDefaultSpacing, right: 4.0),
      child: Row(
        children: [
          Icon(SBBIcons.circle_information_small, color: fontColor),
          const SizedBox(width: sbbDefaultSpacing * 0.5),
          Text(
            '${context.l10n.w_adl_notification_title}: $message',
            style: DASTextStyles.mediumBold.copyWith(color: fontColor),
          ),
        ],
      ),
    );
  }
}
