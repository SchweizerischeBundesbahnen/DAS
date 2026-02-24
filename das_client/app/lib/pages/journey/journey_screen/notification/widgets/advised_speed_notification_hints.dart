import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/assets.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class AdvisedSpeedNotificationHint extends StatelessWidget {
  static const widthWithoutRoundedLeftEdge = 40.0; // width for positioning in parent

  const AdvisedSpeedNotificationHint({required this.hint, required this.roundBottomRightCorner, super.key});

  final AdvisedSpeedSegmentHint hint;
  final bool roundBottomRightCorner;

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _resolveBackgroundColor(context);
    final Widget child = _resolveChild(context);
    return Row(
      mainAxisSize: .min,
      children: [
        SvgPicture.asset(AppAssets.shapeRoundedEdgeLeftLarge, colorFilter: ColorFilter.mode(backgroundColor, .srcIn)),
        Container(
          alignment: .center,
          padding: EdgeInsets.symmetric(horizontal: SBBSpacing.medium, vertical: 14.0).copyWith(left: 0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(SBBSpacing.medium),
              bottomRight: roundBottomRightCorner ? Radius.circular(SBBSpacing.medium) : Radius.zero,
            ),
          ),
          child: child,
        ),
      ],
    );
  }

  Color _resolveBackgroundColor(BuildContext context) {
    return switch (hint) {
      .servicePointWithLocalSpeed => ThemeUtil.getColor(context, SBBColors.charcoal, SBBColors.aluminum),
      .curvePointWithLocalSpeed => ThemeUtil.getColor(context, SBBColors.sky, SBBColors.skyDark),
      .additionalSpeedRestriction => ThemeUtil.getColor(context, SBBColors.orange, SBBColors.orangeDark),
    };
  }

  Widget _resolveChild(BuildContext context) {
    return switch (hint) {
      .servicePointWithLocalSpeed => SvgPicture.asset(AppAssets.stationSignBhf),
      .curvePointWithLocalSpeed => Padding(
        padding: const EdgeInsets.all(2.0),
        child: SvgPicture.asset(
          AppAssets.iconCurveStart,
          colorFilter: ColorFilter.mode(SBBColors.white, .srcIn),
        ),
      ),
      .additionalSpeedRestriction => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
        child: SvgPicture.asset(AppAssets.iconAdditionalSpeedRestriction),
      ),
    };
  }
}
