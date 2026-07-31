import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

/// Adds an indicator to the [child]. Position can be defined with the [offset].
class DotIndicator extends StatelessWidget {
  static const Key indicatorKey = Key('dotIndicator');

  const DotIndicator({
    required this.child,
    this.show = true,
    this.offset = const Offset(0, 0),
    this.size = 8.0,
    this.isNextStop = false,
    this.color,
    super.key,
  });

  final Offset offset;
  final double size;
  final bool show;
  final Widget child;
  final Color? color;
  final bool isNextStop;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;

    return Stack(
      clipBehavior: .none,
      children: [
        child,
        Positioned(
          top: offset.dx,
          right: offset.dy,
          child: indicator(context),
        ),
      ],
    );
  }

  Widget indicator(BuildContext context) {
    return CustomPaint(
      key: indicatorKey,
      painter: _DotPainter(color: _resolvedDotColor(context)),
      size: Size(size, size),
    );
  }

  Color _resolvedDotColor(BuildContext context) {
    if (color != null) return color!;

    final resolvedDotColor = isNextStop
        ? SBBColors.sky
        : ThemeUtil.getColor(context, Theme.of(context).colorScheme.primary, SBBColors.sky);
    return resolvedDotColor;
  }
}

class _DotPainter extends CustomPainter {
  _DotPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 1;

    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.height / 2, paint);
  }

  @override
  bool shouldRepaint(_) => false;
}
