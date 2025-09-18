import 'package:app/pages/journey/train_journey/chevron_animation_controller.dart';
import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:flutter/material.dart';

class ChevronAnimationWrapper extends StatefulWidget {
  const ChevronAnimationWrapper({
    required this.child,
    required this.journeyPosition,
    super.key,
  });

  final Widget child;
  final JourneyPositionModel? journeyPosition;

  @override
  State<ChevronAnimationWrapper> createState() => _ChevronAnimationWrapperState();

  static ChevronAnimationController? of(BuildContext? context) =>
      context?.dependOnInheritedWidgetOfExactType<_ChevronAnimationWrapper>()?.controller;
}

class _ChevronAnimationWrapperState extends State<ChevronAnimationWrapper> with SingleTickerProviderStateMixin {
  late final ChevronAnimationController _controller;

  @override
  void initState() {
    _controller = ChevronAnimationController(this);
    _controller.onPositionUpdate(widget.journeyPosition);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChevronAnimationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journeyPosition != widget.journeyPosition) {
      _controller.onPositionUpdate(widget.journeyPosition);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _ChevronAnimationWrapper(
      controller: _controller,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _ChevronAnimationWrapper extends InheritedWidget {
  const _ChevronAnimationWrapper({
    required this.controller,
    required super.child,
  });

  final ChevronAnimationController controller;

  @override
  bool updateShouldNotify(_ChevronAnimationWrapper oldWidget) => controller != oldWidget.controller;
}
