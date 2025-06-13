import 'package:app/pages/journey/train_journey/widgets/table/cells/route_chevron.dart';
import 'package:app/pages/journey/train_journey/widgets/table/config/chevron_animation_data.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class RouteCellBody extends StatelessWidget {
  static const Key stopKey = Key('stopRouteCell');
  static const Key stopOnRequestKey = Key('stopOnRequestRouteCell');
  static const Key routeStartKey = Key('startRouteCell');
  static const Key routeEndKey = Key('endRouteCell');

  static const double routeCircleSize = 14.0;

  const RouteCellBody({
    super.key,
    this.chevronHeight = 8.0,
    this.chevronWidth = 16.0,
    this.lineThickness = 2.0,
    this.isStop = false,
    this.isStopOnRequest = false,
    this.isCurrentPosition = false,
    this.isRouteStart = false,
    this.isRouteEnd = false,
    this.chevronAnimationData,
  });

  final double chevronHeight;
  final double chevronWidth;
  final double lineThickness;

  final bool isCurrentPosition;
  final bool isStop;
  final bool isStopOnRequest;
  final bool isRouteStart;
  final bool isRouteEnd;

  final ChevronAnimationData? chevronAnimationData;

  @override
  Widget build(BuildContext context) {
    final horizontalBorderWidth =
        DASTableTheme.of(context)?.data.tableBorder?.horizontalInside.width ?? sbbDefaultSpacing;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            _routeLine(context, height, width),
            if (isCurrentPosition || chevronAnimationData != null)
              Positioned(
                top: -horizontalBorderWidth,
                bottom: -horizontalBorderWidth,
                left: 0,
                right: 0,
                child: RouteChevron(
                  isStop: isStop,
                  circleSize: routeCircleSize,
                  chevronWidth: chevronWidth,
                  chevronAnimationData: chevronAnimationData,
                  chevronHeight: chevronHeight,
                ),
              ),
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
    final circleColor = isDarkTheme ? SBBColors.white : SBBColors.black;
    return Positioned(
      bottom: sbbDefaultSpacing,
      child: _RouteCircle(size: routeCircleSize, color: circleColor, isStopOnRequest: isStopOnRequest),
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
    ),
  );
}
