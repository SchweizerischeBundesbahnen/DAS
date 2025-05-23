import 'package:flutter/material.dart';

class IndicatorWrapper extends StatelessWidget {
  static const Key indicatorKey = Key('indicatorKey');

  const IndicatorWrapper({
    required this.show,
    required this.child,
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

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: offset.dx,
          right: offset.dy,
          child: CustomPaint(
            key: indicatorKey,
            painter: _IndicatorPainter(color: Theme.of(context).colorScheme.primary),
            size: Size(size, size),
          ),
        ),
      ],
    );
  }
}

class _IndicatorPainter extends CustomPainter {
  _IndicatorPainter({required this.color});

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
