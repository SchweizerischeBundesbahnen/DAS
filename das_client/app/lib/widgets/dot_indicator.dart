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
    super.key,
  });

  final Offset offset;
  final double size;
  final bool show;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    final resolvedDotColor = SBBColors.sky;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: offset.dx,
          right: offset.dy,
          child: CustomPaint(
            key: indicatorKey,
            painter: _DotPainter(color: resolvedDotColor),
            size: Size(size, size),
          ),
        ),
      ],
    );
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
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
