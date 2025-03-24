import 'dart:math';

import 'package:das_client/app/pages/journey/train_journey/chevron_animation_controller.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/chevron_animation_wrapper.dart';
import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/chevron_animation_data.dart';
import 'package:das_client/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class RouteChevron extends StatefulWidget {
  static const Key chevronKey = Key('chevronCell');

  const RouteChevron({
    required this.isStop,
    required this.circleSize,
    required this.chevronWidth,
    required this.chevronHeight,
    this.chevronAnimationData,
    super.key,
  });

  final bool isStop;
  final double circleSize;
  final double chevronWidth;
  final double chevronHeight;

  final ChevronAnimationData? chevronAnimationData;

  @override
  State<RouteChevron> createState() => _RouteChevronState();
}

class _RouteChevronState extends State<RouteChevron> {
  double currentOffsetValue = 0;
  ChevronAnimationController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller?.removeListener(_animationListener);
    controller = ChevronAnimationWrapper.of(context);
    controller?.addListener(_animationListener);
    _animationListener();
  }

  @override
  void didUpdateWidget(covariant RouteChevron oldWidget) {
    super.didUpdateWidget(oldWidget);
    _animationListener();
  }

  void _animationListener() {
    if (widget.chevronAnimationData != null && controller?.animation != null) {
      final start = min(widget.chevronAnimationData!.offset, 0.0);
      final end = max(widget.chevronAnimationData!.offset, 0.0);
      final diff = (start - end).abs();

      setState(() {
        currentOffsetValue = start + (diff * controller!.animation!.value);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: widget.isStop
          ? sbbDefaultSpacing + widget.circleSize - currentOffsetValue
          : sbbDefaultSpacing - currentOffsetValue,
      child: CustomPaint(
        key: RouteChevron.chevronKey,
        size: Size(widget.chevronWidth, widget.chevronHeight),
        painter: _ChevronPainter(color: ThemeUtil.getColor(context, SBBColors.black, SBBColors.sky)),
      ),
    );
  }

  @override
  void dispose() {
    controller?.removeListener(_animationListener);
    super.dispose();
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
