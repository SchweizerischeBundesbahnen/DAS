import 'package:design_system_flutter/design_system_flutter.dart';
import 'package:flutter/material.dart';

class RouteCellBody extends StatelessWidget {
  const RouteCellBody({
    super.key,
    this.chevronHeight = 8.0,
    this.chevronWidth = 16.0,
    this.circleSize = 14.0,
    this.lineThickness = 2.0,
    this.showCircle = false,
    this.showChevron = false,
  });

  final double chevronHeight;
  final double chevronWidth;
  final double circleSize;
  final double lineThickness;

  final bool showChevron;
  final bool showCircle;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        if (showChevron) _chevron(),
        if (showCircle) _circle(),
        _routeLine(),
      ],
    );
  }

  Positioned _routeLine() {
    return Positioned(
      top: -sbbDefaultSpacing,
      bottom: -sbbDefaultSpacing,
      right: 0,
      left: 0,
      child: VerticalDivider(thickness: lineThickness, color: SBBColors.black),
    );
  }

  Positioned _circle() {
    return Positioned(
      bottom: sbbDefaultSpacing,
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: SBBColors.black,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Positioned _chevron() {
    final bottomSpacing = showCircle ? sbbDefaultSpacing + circleSize : sbbDefaultSpacing;
    return Positioned(
      bottom: bottomSpacing,
      child: CustomPaint(
        size: Size(chevronWidth, chevronHeight),
        painter: _ChevronPainter(),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
