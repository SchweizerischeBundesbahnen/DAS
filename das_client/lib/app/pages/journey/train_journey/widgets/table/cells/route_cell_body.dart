import 'package:das_client/app/widgets/table/das_table_theme.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:flutter/material.dart';

class RouteCellBody extends StatelessWidget {
  static const Key stopKey = Key('stopRouteCell');
  static const Key stopOnRequestKey = Key('stopOnRequestRouteCell');
  static const Key routeStartKey = Key('startRouteCell');
  static const Key routeEndKey = Key('endRouteCell');

  const RouteCellBody({
    super.key,
    this.chevronHeight = 8.0,
    this.chevronWidth = 16.0,
    this.circleSize = 14.0,
    this.lineThickness = 2.0,
    this.isStop = false,
    this.isStopOnRequest = false,
    this.isCurrentPosition = false,
    this.isRouteStart = false,
    this.isRouteEnd = false,
  });

  final double chevronHeight;
  final double chevronWidth;
  final double circleSize;
  final double lineThickness;

  final bool isCurrentPosition;
  final bool isStop;
  final bool isStopOnRequest;
  final bool isRouteStart;
  final bool isRouteEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _routeLine(context, height, width),
            if (isCurrentPosition) _chevron(context),
            if (isStop) _circle(context),
          ],
        );
      },
    );
  }

  Widget _routeLine(BuildContext context, double height, double width) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final lineColor = isDarkTheme ? SBBColors.white : SBBColors.black;
    final horizontalBorderWidth =
        DASTableTheme.of(context)?.data.tableBorder?.horizontalInside.width ?? sbbDefaultSpacing;
    return Positioned(
      key: _routeKey(),
      top: isRouteStart ? height - sbbDefaultSpacing : 0,
      bottom: isRouteEnd ? sbbDefaultSpacing : -horizontalBorderWidth,
      left: (width / 2) - (lineThickness / 2),
      child: VerticalDivider(thickness: lineThickness, color: lineColor),
    );
  }

  Positioned _circle(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final circleColor = isDarkTheme ? SBBColors.sky : SBBColors.black;
    return Positioned(
      bottom: sbbDefaultSpacing,
      child: _RouteCircle(size: circleSize, color: circleColor, isStopOnRequest: isStopOnRequest),
    );
  }

  Positioned _chevron(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final chevronColor = isDarkTheme ? SBBColors.sky : SBBColors.black;
    return Positioned(
      bottom: isStop ? sbbDefaultSpacing + circleSize : sbbDefaultSpacing,
      child: CustomPaint(
        size: Size(chevronWidth, chevronHeight),
        painter: _ChevronPainter(color: chevronColor),
      ),
    );
  }

  Key? _routeKey() {
    if (!isRouteStart && !isRouteEnd) {
      return null;
    }
    return isRouteStart ? routeStartKey : routeEndKey;
  }
}

class _RouteCircle extends StatelessWidget {
  const _RouteCircle({
    required this.size,
    required this.color,
    this.isStopOnRequest = false,
  });

  final bool isStopOnRequest;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tableThemeData = DASTableTheme.of(context)?.data;
    final tableBackgroundColor = tableThemeData?.backgroundColor ?? SBBColors.white;
    return Container(
      key: isStopOnRequest ? RouteCellBody.stopOnRequestKey : RouteCellBody.stopKey,
      width: size,
      height: size,
      decoration: isStopOnRequest ? _stopOnRequestDecoration(backgroundColor: tableBackgroundColor) : _stopDecoration(),
    );
  }

  BoxDecoration _stopDecoration() => BoxDecoration(color: color, shape: BoxShape.circle);

  BoxDecoration _stopOnRequestDecoration({required Color backgroundColor}) => BoxDecoration(
      color: backgroundColor,
      shape: BoxShape.circle,
      border: Border.all(
        color: color, // Set the border color
        width: 2.0, // Set the border width
      ));
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
