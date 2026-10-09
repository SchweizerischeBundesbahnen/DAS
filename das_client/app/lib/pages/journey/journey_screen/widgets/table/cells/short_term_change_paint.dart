import 'dart:math';

import 'package:flutter/widgets.dart';

class ShortTermChangePaint extends StatelessWidget {
  const ShortTermChangePaint({
    required this.isStart,
    required this.size,
    required this.color,
    required this.thickness,
    super.key,
  });

  final bool isStart;
  final Size size;
  final Color color;
  final double thickness;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: size,
      painter: _ShortTermChangePainter(
        isStart: isStart,
        color: color,
        thickness: thickness,
      ),
    );
  }
}

class const _ShortTermChangePainter({
  required final bool isStart,
  required final Color color,
  required final double thickness,
}) extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = thickness;

    if (isStart) {
      final path = Path()
        ..addArc(Rect.fromLTWH(0, 0, size.width, size.width), 0, pi / 2)
        ..addArc(Rect.fromLTWH(0, size.width, size.width, size.width), pi * 3 / 2, -pi / 2);

      canvas.drawPath(path, paint);
    } else {
      final path = Path()
        ..lineTo(0, size.height - size.width)
        ..addArc(Rect.fromLTWH(0, size.height - size.width - size.width / 2, size.width, size.width), pi / 2, pi / 2)
        ..addArc(Rect.fromLTWH(0, size.height - size.width / 2, size.width, size.width), pi * 3 / 2, pi / 2);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShortTermChangePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.thickness != thickness;
  }
}
