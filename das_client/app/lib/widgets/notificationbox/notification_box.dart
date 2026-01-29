import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

part 'notification_box_style.dart';

class NotificationBox extends StatelessWidget {
  const NotificationBox({required this.style, required this.title, this.action, this.text, this.customIcon, super.key});

  final NotificationBoxStyle style;
  final String title;
  final Widget? action;
  final String? text;
  final IconData? customIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: style.backgroundColor, width: SBBSpacing.xSmall),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(SBBSpacing.medium),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: style.backgroundColor),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8.0),
            bottomLeft: Radius.circular(8.0),
            topRight: Radius.circular(15.0),
            bottomRight: Radius.circular(15.0),
          ),
          color: style.backgroundColor.withAlpha((255.0 * .05).round()),
        ),
        padding: const .all(SBBSpacing.xSmall),
        child: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          spacing: SBBSpacing.xSmall,
          children: [
            Icon(
              customIcon ?? style.icon,
              color: ThemeUtil.getColor(context, style.iconColor, style.iconColorDark),
            ),
            Expanded(
              child: Text(
                title,
                style: sbbTextStyle.boldStyle.medium,
              ),
            ),
            if (action != null) action!,
          ],
        ),
        if (text != null)
          Text(
            text!,
            style: sbbTextStyle.lightStyle.small,
          ),
      ],
    );
  }
}
