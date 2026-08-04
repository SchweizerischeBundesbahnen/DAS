import 'package:app/widgets/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ShortTermChangeExclamationIcon extends StatelessWidget {
  static const Key iconKey = Key('shortTermChangeExclamationIcon');

  const ShortTermChangeExclamationIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconTabIndicatorExclamationTurquoise,
      key: iconKey,
    );
  }
}
