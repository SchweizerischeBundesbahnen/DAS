import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// A simple filled circle, intended to be used as a badge via [DASBadgeOverlay].
class DASCircleBadge extends StatelessWidget {
  static const Key circleBadgeKey = Key('circleBadgeKey');

  const DASCircleBadge({
    this.color,
    super.key,
  });

  /// Falls back to the Theme primary color or [SBBColors.sky] in dark mode.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      key: circleBadgeKey,
      painter: _CirclePainter(color: color ?? _defaultColor(context)),
      size: Size.square(SBBSpacing.xSmall),
    );
  }

  Color _defaultColor(BuildContext context) {
    return Theme.brightnessOf(context) == .dark ? SBBColors.sky : Theme.of(context).colorScheme.primary;
  }
}

class _CirclePainter({required final Color color}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.height / 2, paint);
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => oldDelegate.color != color;
}
