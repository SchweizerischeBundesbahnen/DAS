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
        if (showChevron) _chevron(context),
        if (showCircle) _circle(context),
        _routeLine(context),
      ],
    );
  }

  Positioned _routeLine(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final lineColor = isDarkTheme ? SBBColors.white : SBBColors.black;
    return Positioned(
      top: -sbbDefaultSpacing,
      bottom: -sbbDefaultSpacing,
      right: 0,
      left: 0,
      child: VerticalDivider(thickness: lineThickness, color: lineColor),
    );
  }

  Positioned _circle(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final circleColor = isDarkTheme ? SBBColors.sky : SBBColors.black;
    return Positioned(
      bottom: sbbDefaultSpacing,
      child: Container(
        width: circleSize,
        height: circleSize,
        decoration: BoxDecoration(
          color: circleColor,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Positioned _chevron(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final chevronColor = isDarkTheme ? SBBColors.sky : SBBColors.black;
    return Positioned(
      bottom: showCircle ? sbbDefaultSpacing + circleSize : sbbDefaultSpacing,
      child: CustomPaint(
        size: Size(chevronWidth, chevronHeight),
        painter: _ChevronPainter(color: chevronColor),
      ),
    );
  }
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter({this.color = SBBColors.black});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
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
