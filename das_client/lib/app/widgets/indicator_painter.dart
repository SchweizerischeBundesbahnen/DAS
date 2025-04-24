import 'package:flutter/material.dart';

class IndicatorPainter extends CustomPainter {
  IndicatorPainter({required this.color});

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
