import 'package:app/pages/journey/journey_table/chevron_animation_controller.dart';
import 'package:app/pages/journey/journey_table/widgets/chevron_animation_wrapper.dart';
import 'package:app/pages/journey/journey_table/widgets/table/config/chevron_animation_data.dart';
import 'package:app/theme/theme_util.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class RouteChevron extends StatefulWidget {
  static const Key chevronKey = Key('chevronCell');
  static const double chevronHeight = 8.0;

  const RouteChevron({
    required this.chevronWidth,
    required this.chevronPosition,
    this.chevronAnimationData,
    super.key,
  });

  final double chevronWidth;
  final double chevronPosition;

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
      final start = widget.chevronAnimationData!.startOffset;
      final end = widget.chevronAnimationData!.endOffset;
      final reversed = start > end;
      final diff = (start - end).abs();

      setState(() {
        if (controller?.currentPosition == widget.chevronAnimationData?.currentPosition &&
            controller?.lastPosition == widget.chevronAnimationData?.lastPosition) {
          currentOffsetValue =
              start + (reversed ? -(diff * controller!.animation!.value) : (diff * controller!.animation!.value));
        } else {
          currentOffsetValue = end;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      alignment: Alignment.center,
      children: [
        Positioned(
          top: widget.chevronPosition + currentOffsetValue,
          child: CustomPaint(
            key: RouteChevron.chevronKey,
            size: Size(widget.chevronWidth, RouteChevron.chevronHeight),
            painter: _ChevronPainter(
              color: ThemeUtil.getColor(context, SBBColors.black, SBBColors.white),
            ),
          ),
        ),
      ],
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
