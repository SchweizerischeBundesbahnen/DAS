import 'package:app/util/animation.dart';
import 'package:flutter/material.dart';
import 'package:sbb_design_system_mobile/sbb_design_system_mobile.dart';

class AnimatedMainHeaderBox extends StatefulWidget {
  const AnimatedMainHeaderBox({
    required this.showFlap,
    required this.mainContentHeight,
    required this.mainContent,
    required this.flapHeight,
    required this.flap,
    super.key,
    this.duration = DASAnimation.mediumDuration,
  });

  final bool showFlap;
  final Duration duration;
  final double mainContentHeight;
  final double flapHeight;
  final Widget flap;
  final Widget mainContent;

  @override
  State<AnimatedMainHeaderBox> createState() => _AnimatedMainHeaderBoxState();
}

class _AnimatedMainHeaderBoxState extends State<AnimatedMainHeaderBox> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _sizeAnimation =
        Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeInOut,
          ),
        );

    if (widget.showFlap) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedMainHeaderBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.showFlap != oldWidget.showFlap) {
      if (widget.showFlap) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: widget.mainContentHeight + _sizeAnimation.value * widget.flapHeight,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(SBBSpacing.medium)),
                child: widget.flap,
              ),
            ),
            widget.mainContent,
          ],
        );
      },
    );
  }
}
