import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';
import 'package:das_client/i18n/src/build_context_x.dart';

class ADLNotification extends StatelessWidget {
  const ADLNotification({super.key, required this.message, this.margin});

  final String message;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: SBBColors.charcoal,
        borderRadius: BorderRadius.circular(sbbDefaultSpacing),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14.0)
          .copyWith(left: sbbDefaultSpacing, right: 4.0),
      child: Row(
        children: [
          const Icon(SBBIcons.circle_information_small, color: SBBColors.white),
          const SizedBox(width: sbbDefaultSpacing * 0.5),
          Text(
            '${context.l10n.w_adl_notification_title}: $message',
            style: SBBTextStyles.mediumBold.copyWith(color: SBBColors.white),
          ),
        ],
      ),
    );
  }
}
