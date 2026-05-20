import 'package:app/widgets/assets.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UTurnIndicator extends DotIndicator {
  static const Key indicatorKey = Key('uTurnShortTermChangeIndicator');

  const UTurnIndicator({
    required super.child,
    super.show,
    super.offset,
    super.size,
    super.isNextStop,
    super.key,
    this.foregroundColor,
  });

  final Color? foregroundColor;

  @override
  Widget indicator(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconUturnTurquoise,
      key: indicatorKey,
      colorFilter: foregroundColor != null ? ColorFilter.mode(foregroundColor!, BlendMode.srcIn) : null,
    );
  }
}
