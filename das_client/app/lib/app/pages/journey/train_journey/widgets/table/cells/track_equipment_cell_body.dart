import 'dart:math';

import 'package:app/app/pages/journey/train_journey/widgets/table/cells/route_cell_body.dart';
import 'package:app/app/pages/journey/train_journey/widgets/table/config/track_equipment_render_data.dart';
import 'package:app/app/widgets/table/das_table_theme.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';
import 'package:sfera/component.dart';

class TrackEquipmentCellBody extends StatelessWidget {
  static const Key conventionalExtendedSpeedBorderKey = Key('conventionalExtendedSpeedBorder');
  static const Key twoTracksWithSingleTrackEquipmentKey = Key('twoTracksWithSingleTrackEquipment');
  static const Key conventionalSpeedReversingImpossibleKey = Key('conventionalSpeedReversingImpossible');
  static const Key extendedSpeedReversingPossibleKey = Key('extendedSpeedReversingPossible');
  static const Key extendedSpeedReversingImpossibleKey = Key('extendedSpeedReversingImpossible');
  static const Key singleTrackNoBlockKey = Key('singleTrackNoBlock');

  const TrackEquipmentCellBody({
    this.renderData = const TrackEquipmentRenderData(),
    super.key,
  });

  final TrackEquipmentRenderData renderData;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        final trackEquipmentType = renderData.trackEquipmentType;
        return Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            if (renderData.isConventionalExtendedSpeedBorder) _conventionalExtendedSpeedBorder(context),
            if (trackEquipmentType == TrackEquipmentType.etcsL2ExtSpeedReversingPossible)
              _extSpeedReversingPossible(context, height),
            if (trackEquipmentType == TrackEquipmentType.etcsL2ExtSpeedReversingImpossible)
              _extSpeedReversingImpossible(context, height),
            if (trackEquipmentType == TrackEquipmentType.etcsL2ConvSpeedReversingImpossible)
              _convSpeedReversingImpossible(context, height),
            if (trackEquipmentType == TrackEquipmentType.etcsL1ls2TracksWithSingleTrackEquipment)
              _twoTracksWithSingleTrackEquipment(context, height),
            if (trackEquipmentType == TrackEquipmentType.etcsL1lsSingleTrackNoBlock)
              _singleTrackNoBlock(context, height),
          ],
        );
      },
    );
  }

  Widget _extSpeedReversingPossible(BuildContext context, double height) {
    return Positioned(
      key: extendedSpeedReversingPossibleKey,
      top: _calculateTop(height),
      bottom: _calculateBottom(context, height),
      left: 2.0,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _extSpeedLine(context),
          SizedBox(width: 2.0),
          _extSpeedLine(context),
        ],
      ),
    );
  }

  Widget _conventionalExtendedSpeedBorder(BuildContext context) {
    return Positioned(
      key: conventionalExtendedSpeedBorderKey,
      top: 0.0,
      left: 0.0,
      child: CustomPaint(
        painter: _ConventionalExtendedSpeedBorderPainter(context: context),
      ),
    );
  }

  Widget _extSpeedReversingImpossible(BuildContext context, double height) {
    return Positioned(
      key: extendedSpeedReversingImpossibleKey,
      top: _calculateTop(height),
      bottom: _calculateBottom(context, height),
      left: 2.0,
      child: _extSpeedLine(context),
    );
  }

  CustomPaint _extSpeedLine(BuildContext context) {
    final width = 3.0;
    return CustomPaint(
      painter: _CumulativeDashedLinePainter(
        context: context,
        cumulativeHeight: renderData.cumulativeHeight,
        dashHeights: [7.0],
        dashSpace: 5.0,
        width: width,
      ),
      child: SizedBox(height: double.infinity, width: width),
    );
  }

  Widget _convSpeedReversingImpossible(BuildContext context, double height) {
    final width = 3.0;
    return Positioned(
      key: TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey,
      top: _calculateTop(height),
      bottom: _calculateBottom(context, height),
      left: 2.0,
      child: CustomPaint(
        painter: _CumulativeDashedLinePainter(
          context: context,
          cumulativeHeight: renderData.cumulativeHeight,
          dashHeights: [3.0, 7.0],
          dashSpace: 5.0,
          width: width,
        ),
        child: SizedBox(height: double.infinity, width: width),
      ),
    );
  }

  Widget _twoTracksWithSingleTrackEquipment(BuildContext context, double height) {
    final width = 3.0;
    final borderWidth = 1.0;
    return Positioned(
      key: twoTracksWithSingleTrackEquipmentKey,
      top: _calculateTop(height),
      bottom: _calculateBottom(context, height),
      left: 1.0,
      child: CustomPaint(
        key: TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey,
        painter: _CumulativeDashedLinePainter(
          context: context,
          cumulativeHeight: renderData.cumulativeHeight,
          dashHeights: [7.0],
          dashSpace: 5.0,
          width: width,
          borderWidth: borderWidth,
        ),
        child: SizedBox(height: double.infinity, width: width + borderWidth * 2),
      ),
    );
  }

  Widget _singleTrackNoBlock(BuildContext context, double height) {
    final width = 9.0;
    return Positioned(
      key: singleTrackNoBlockKey,
      top: _calculateTop(height),
      bottom: _calculateBottom(context, height),
      left: 1.0,
      child: CustomPaint(
        key: TrackEquipmentCellBody.conventionalSpeedReversingImpossibleKey,
        painter: _SingleTrackNoBlockPainter(cumulativeHeight: renderData.cumulativeHeight, context: context),
        child: SizedBox(height: double.infinity, width: width),
      ),
    );
  }

  /// calculation of bottom is used to draw over table border and handle start or end if necessary
  double _calculateBottom(BuildContext context, double height) {
    if (renderData.isStart && renderData.isEnd) {
      return height * 0.25;
    } else if (renderData.isEnd && renderData.dataType == ServicePoint) {
      return sbbDefaultSpacing + RouteCellBody.routeCircleSize / 2;
    } else if (renderData.isEnd) {
      return height * 0.5;
    }

    final tableBorder = DASTableTheme.of(context)?.data.tableBorder;
    return -(tableBorder?.horizontalInside.width ?? 0);
  }

  /// calculation of top is used to draw over table border and handle start or end if necessary
  double _calculateTop(double height) {
    if (renderData.isStart && renderData.isEnd) {
      return height * 0.25;
    } else if (renderData.isStart && renderData.dataType == ServicePoint) {
      return height - sbbDefaultSpacing - RouteCellBody.routeCircleSize / 2;
    } else if (renderData.isStart) {
      return height * 0.5;
    }

    return renderData.isConventionalExtendedSpeedBorder ? conventionalExtendedSpeedBorderSpace : 0;
  }

  static double get conventionalExtendedSpeedBorderSpace => 5.0 + _ConventionalExtendedSpeedBorderPainter.height;
}

class _ConventionalExtendedSpeedBorderPainter extends CustomPainter {
  const _ConventionalExtendedSpeedBorderPainter({required this.context});

  final BuildContext context;

  static const double height = 3.0;
  static const double width = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ThemeUtil.getIconColor(context)
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(0, 0, width, height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _CumulativeDashedLinePainter extends CustomPainter {
  _CumulativeDashedLinePainter({
    required this.context,
    required this.cumulativeHeight,
    this.dashHeights = const [4.0],
    this.dashSpace = 4.0,
    this.width = 3.0,
    this.borderWidth,
  }) : assert(dashHeights.isNotEmpty);

  final BuildContext context;
  final double cumulativeHeight;
  final List<double> dashHeights;
  final double dashSpace;
  final double width;
  final double? borderWidth;

  @override
  void paint(Canvas canvas, Size size) {
    // Determine the offset in the cycle based on the cumulative height
    final dashPatternLength = dashHeights.reduce((a, b) => a + b) + (dashSpace * (dashHeights.length));
    final offsetInPattern = cumulativeHeight % dashPatternLength;

    final paint = Paint()
      ..color = ThemeUtil.getIconColor(context)
      ..strokeWidth = width;

    int dashIndex = 0;
    double startY = -offsetInPattern;
    double endY = 0;
    while (startY < size.height) {
      dashIndex = dashIndex % dashHeights.length;
      endY = startY + dashHeights[dashIndex];
      if (endY > 0) {
        canvas.drawLine(Offset(size.width * 0.5, startY), Offset(size.width * 0.5, endY), paint);
      }
      startY = endY + dashSpace;
      dashIndex++;
    }

    // adds border on left/right of dashed line
    if (borderWidth != null) {
      _drawBorder(canvas, size, endY);
    }
  }

  void _drawBorder(Canvas canvas, Size size, double patternEndY) {
    final borderPaint = Paint()
      ..color = ThemeUtil.getIconColor(context)
      ..strokeWidth = borderWidth!;

    final endY = max(size.height, patternEndY);

    // Draw left border line
    final leftDx = (size.width - width - borderWidth!) * 0.5;
    canvas.drawLine(Offset(leftDx, 0), Offset(leftDx, endY), borderPaint);

    // Draw right border line
    final rightDx = (size.width + width + borderWidth!) * 0.5;
    canvas.drawLine(Offset(rightDx, 0), Offset(rightDx, endY), borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _SingleTrackNoBlockPainter extends CustomPainter {
  _SingleTrackNoBlockPainter({required this.cumulativeHeight, required this.context});

  final double cumulativeHeight;
  final BuildContext context;
  static const double _strokeWidth = 3.0;
  static const double _dashHeight = 6.0;
  static const double _crossSize = 9.0;
  static const double _spacing = 5.0;

  @override
  void paint(Canvas canvas, Size size) {
    // Determine the offset in the cycle based on the cumulative height
    final patternLength = _dashHeight + _crossSize + 2 * _spacing;
    final offsetInPattern = cumulativeHeight % patternLength;

    final paint = Paint()
      ..color = ThemeUtil.getIconColor(context)
      ..strokeWidth = _strokeWidth;

    var drawCross = false;
    double startY = -offsetInPattern;
    double endY = 0;
    while (startY < size.height) {
      if (drawCross) {
        endY = startY + _crossSize;

        // to draw the rotated cross, the whole canvas is rotated.
        canvas.save();
        canvas.translate(_crossSize / 2, startY + _crossSize / 2);
        canvas.rotate(45 * (3.14159 / 180)); // Rotate the canvas by 45 degrees (in radians)
        canvas.drawLine(Offset(0, -_crossSize / 2), Offset(0, _crossSize / 2), paint); // vertical line
        canvas.drawLine(Offset(-_crossSize / 2, 0), Offset(_crossSize / 2, 0), paint); // horizontal line
        canvas.restore();
      } else {
        endY = startY + _dashHeight;
        canvas.drawLine(Offset(size.width * 0.5, startY), Offset(size.width * 0.5, endY), paint);
      }

      drawCross = !drawCross;
      startY = endY + _spacing;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
