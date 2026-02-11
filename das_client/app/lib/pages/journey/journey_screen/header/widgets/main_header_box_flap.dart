import 'package:app/pages/journey/journey_screen/header/widgets/main_header_box.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/widgets.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class ShortTermChangeHeaderBoxFlap extends StatelessWidget {
  const ShortTermChangeHeaderBoxFlap({required this.child, super.key});

  static double get height => 36.0;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final backgroundColor = ThemeUtil.getColor(context, SBBColors.turquoise, SBBColors.turquoiseDark);
    return SizedBox(
      height: MainHeaderBox.height + height,
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(color: backgroundColor),
        child: Align(
          alignment: .bottomLeft,
          child: child,
        ),
      ),
    );
  }
}
