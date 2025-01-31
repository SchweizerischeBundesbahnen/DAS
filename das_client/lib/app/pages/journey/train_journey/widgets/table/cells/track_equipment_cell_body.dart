import 'dart:math';

import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/track_equipment_render_data.dart';
import 'package:das_client/app/widgets/table/das_table_theme.dart';
import 'package:das_client/model/journey/track_equipment_segment.dart';
import 'package:flutter/material.dart';

class TrackEquipmentCellBody extends StatelessWidget {
  static const Key conventionalExtendedSpeedBorderKey = Key('conventional_extended_speed_border_key');
  static const Key twoTracksWithSingleTrackEquipmentKey = Key('two_tracks_with_single_track_equipment_key');
  static const Key extendedSpeedReversingPossibleKey = Key('extended_speed_reversing_possible_key');
  static const Key extendedSpeedReversingImpossibleKey = Key('extended_speed_reversing_impossible_key');
  static const Key conventionalSpeedReversingImpossible = Key('conventional_speed_reversing_impossible_key');

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
          _extSpeedLine(),
          SizedBox(width: 2.0),
          _extSpeedLine(),
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
        painter: _ConventionalExtendedSpeedBorderPainter(),
      ),
    );
  }

  Widget _extSpeedReversingImpossible(BuildContext context, double height) {
    return Positioned(
      key: extendedSpeedReversingImpossibleKey,
      top: _calculateTop(height),
      bottom: _calculateBottom(context, height),
      left: 2.0,
      child: _extSpeedLine(),
    );
  }

  CustomPaint _extSpeedLine() {
    final width = 3.0;
    return CustomPaint(
      painter: _CumulativeDashedLinePainter(
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
      key: TrackEquipmentCellBody.conventionalSpeedReversingImpossible,
      top: _calculateTop(height),
      bottom: _calculateBottom(context, height),
      left: 2.0,
      child: CustomPaint(
        painter: _CumulativeDashedLinePainter(
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
        key: TrackEquipmentCellBody.conventionalSpeedReversingImpossible,
        painter: _CumulativeDashedLinePainter(
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

  /// calculation of bottom is used to draw over table border and handle start or end if necessary
  double _calculateBottom(BuildContext context, double height) {
    if (renderData.isStart && renderData.isEnd) return height * 0.25;
    if (renderData.isEnd) return height * 0.5;

    final tableBorder = DASTableTheme.of(context)?.data.tableBorder;
    return -(tableBorder?.horizontalInside.width ?? 0);
  }

  /// calculation of top is used to draw over table border and handle start or end if necessary
  double _calculateTop(double height) {
    if (renderData.isStart && renderData.isEnd) return height * 0.25;
    if (renderData.isStart) return height * 0.5;

    return renderData.isConventionalExtendedSpeedBorder ? conventionalExtendedSpeedBorderSpace : 0;
  }

  static double get conventionalExtendedSpeedBorderSpace => 5.0 + _ConventionalExtendedSpeedBorderPainter.height;
}

class _ConventionalExtendedSpeedBorderPainter extends CustomPainter {
  static const double height = 3.0;
  static const double width = 10.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
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
    required this.cumulativeHeight,
    this.dashHeights = const [4.0],
    this.dashSpace = 4.0,
    this.width = 3.0,
    this.borderWidth,
  }) : assert(dashHeights.isNotEmpty);

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
      ..color = Colors.black
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
      ..color = Colors.black
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
