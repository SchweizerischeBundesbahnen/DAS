import 'package:app/pages/journey/journey_screen/widgets/table/cells/route_chevron.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/config/chevron_animation_data.dart';
import 'package:app/pages/journey/journey_screen/widgets/table/service_point_row.dart';
import 'package:app/theme/theme_util.dart';
import 'package:app/widgets/table/das_table_theme.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class RouteCellBody extends StatelessWidget {
  static const Key stopKey = Key('stopRouteCell');
  static const Key stopOnRequestKey = Key('stopOnRequestRouteCell');
  static const Key routeStartKey = Key('startRouteCell');
  static const Key routeEndKey = Key('endRouteCell');

  static const double routeCircleSize = 14.0;
  static const double routeCirclePosition = ServicePointRow.baseRowHeight - sbbDefaultSpacing - routeCircleSize;

  const RouteCellBody({
    required this.chevronPosition,
    super.key,
    this.chevronWidth = 16.0,
    this.lineThickness = 2.0,
    this.isStop = false,
    this.isStopOnRequest = false,
    this.isCurrentPosition = false,
    this.isRouteStart = false,
    this.isRouteEnd = false,
    this.chevronAnimationData,
    this.routeColor,
  });

  final double chevronWidth;
  final double lineThickness;
  final double chevronPosition;

  final bool isCurrentPosition;
  final bool isStop;
  final bool isStopOnRequest;
  final bool isRouteStart;
  final bool isRouteEnd;

  final Color? routeColor;

  final ChevronAnimationData? chevronAnimationData;

  @override
  Widget build(BuildContext context) {
    if (routeColor != null) return _coloredRoute(_route());

    return _route();
  }

  Widget _route() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final width = constraints.maxWidth;
        return Stack(
          clipBehavior: .none,
          alignment: .center,
          children: [
            _routeLine(context, height, width),
            if (isCurrentPosition || chevronAnimationData != null) _chevron(context),
            if (isStop) _circle(context),
          ],
        );
      },
    );
  }

  Widget _coloredRoute(Widget child) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(routeColor!, BlendMode.srcATop),
      child: child,
    );
  }

  Widget _chevron(BuildContext context) {
    final horizontalBorderWidth =
        DASTableTheme.of(context)?.data.tableBorder?.horizontalInside.width ?? sbbDefaultSpacing;
    return Positioned(
      top: -horizontalBorderWidth,
      bottom: -horizontalBorderWidth,
      left: 0,
      right: 0,
      child: RouteChevron(
        chevronWidth: chevronWidth,
        chevronAnimationData: chevronAnimationData,
        chevronPosition: isRouteEnd ? routeCirclePosition - RouteChevron.chevronHeight : chevronPosition,
      ),
    );
  }

  Widget _routeLine(BuildContext context, double height, double width) {
    final lineColor = ThemeUtil.isDarkMode(context) ? SBBColors.white : SBBColors.black;
    final horizontalBorderWidth =
        DASTableTheme.of(context)?.data.tableBorder?.horizontalInside.width ?? sbbDefaultSpacing;
    return Positioned(
      key: _routeKey(),
      top: isRouteStart ? routeCirclePosition + routeCircleSize / 2 : 0,
      bottom: isRouteEnd ? height - routeCirclePosition - routeCircleSize / 2 : -horizontalBorderWidth,
      left: (width / 2) - (lineThickness / 2),
      child: VerticalDivider(thickness: lineThickness, color: lineColor),
    );
  }

  Positioned _circle(BuildContext context) {
    final circleColor = ThemeUtil.isDarkMode(context) ? SBBColors.white : SBBColors.black;
    return Positioned(
      top: routeCirclePosition,
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
    border: Border.all(color: color, width: 2.0),
  );
}
