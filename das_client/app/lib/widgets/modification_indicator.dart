import 'package:app/widgets/assets.dart';
import 'package:app/widgets/dot_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ModificationIndicator extends DotIndicator {
  static const Key indicatorKey = Key('modificationIndicator');

  const ModificationIndicator({
    required super.child,
    super.show,
    super.offset,
    super.size,
    super.isNextStop,
    super.key,
  });

  @override
  Widget indicator(BuildContext context) {
    return SvgPicture.asset(
      AppAssets.iconModificationIndicator,
      key: indicatorKey,
    );
  }
}
