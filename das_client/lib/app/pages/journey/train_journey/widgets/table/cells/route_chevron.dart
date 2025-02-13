import 'package:das_client/app/pages/journey/train_journey/widgets/table/config/chevron_animation_data.dart';
import 'package:das_client/model/journey/metadata.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class RouteChevron extends StatefulWidget {
  static const Key chevronKey = Key('chevronCell');

  const RouteChevron({
    required this.metadata,
    required this.isStop,
    required this.circleSize,
    required this.chevronWidth,
    required this.chevronHeight,
    this.chevronAnimationData,
    super.key,
  });

  final Metadata metadata;
  final bool isStop;
  final double circleSize;
  final double chevronWidth;
  final double chevronHeight;

  final ChevronAnimationData? chevronAnimationData;

  @override
  State<RouteChevron> createState() => _RouteChevronState();
}

class _RouteChevronState extends State<RouteChevron> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  AnimationController? controller;
  double currentOffsetValue = 0;

  @override
  void initState() {
    super.initState();
    // Only animate if the position update came in the last second, otherwise it will be repeated on every scroll
    if (widget.chevronAnimationData != null &&
        DateTime.now().compareTo(widget.metadata.timestamp.add(Duration(seconds: 1))) < 0) {
      currentOffsetValue = widget.chevronAnimationData!.offset;

      controller =
          AnimationController(duration: Duration(milliseconds: widget.chevronAnimationData!.durationMs), vsync: this);
      animation = Tween<double>(begin: widget.chevronAnimationData!.offset, end: 0).animate(controller!)
        ..addListener(() {
          setState(() {
            currentOffsetValue = animation.value;
          });
        });
      controller!.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkTheme = SBBBaseStyle.of(context).brightness == Brightness.dark;
    final chevronColor = isDarkTheme ? SBBColors.sky : SBBColors.black;
    return Positioned(
      bottom: widget.isStop
          ? sbbDefaultSpacing + widget.circleSize + currentOffsetValue
          : sbbDefaultSpacing + currentOffsetValue,
      child: CustomPaint(
        key: RouteChevron.chevronKey,
        size: Size(widget.chevronWidth, widget.chevronHeight),
        painter: _ChevronPainter(color: chevronColor),
      ),
    );
  }

  @override
  dispose() {
    controller?.dispose();
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
