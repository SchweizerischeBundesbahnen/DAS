import 'package:app/widgets/das_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

part 'notification_box_style.dart';

class NotificationBox extends StatelessWidget {
  const NotificationBox({required this.style, required this.text, this.action, super.key});

  final NotificationBoxStyle style;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: style.backgroundColor, width: sbbDefaultSpacing / 2),
        ),
        borderRadius: const BorderRadius.all(
          Radius.circular(sbbDefaultSpacing),
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
        padding: const EdgeInsets.all(sbbDefaultSpacing / 2),
        child: _content(context),
      ),
    );
  }

  Widget _content(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Row(
      children: [
        Icon(
          style.icon,
          color: brightness == Brightness.light ? style.iconColor : style.iconColorDark,
        ),
        const SizedBox(width: sbbDefaultSpacing / 2),
        Expanded(
          child: Text(
            text,
            style: DASTextStyles.mediumBold,
          ),
        ),
        if (action != null) action!,
      ],
    );
  }
}
