import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class UTurnIcon extends StatelessWidget {
  static const Key indicatorKey = Key('uTurnIconKey');

  const UTurnIcon({this.foregroundColor, super.key});

  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconUturnTurquoise,
      key: indicatorKey,
      colorFilter: foregroundColor != null ? ColorFilter.mode(foregroundColor!, BlendMode.srcIn) : null,
    );
  }
}
