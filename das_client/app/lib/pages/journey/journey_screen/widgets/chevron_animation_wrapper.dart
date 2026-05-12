import 'package:app/pages/journey/journey_screen/chevron_animation_controller.dart';
import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
import 'package:flutter/material.dart';

class ChevronAnimationWrapper extends StatefulWidget {
  const ChevronAnimationWrapper({
    required this.child,
    required this.chevronPosition,
    super.key,
  });

  final Widget child;
  final ChevronPositionModel chevronPosition;

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
    _controller.onPositionUpdate(widget.chevronPosition);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChevronAnimationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_relevantPositionUpdate(oldWidget)) {
      _controller.onPositionUpdate(widget.chevronPosition);
    }
  }

  bool _relevantPositionUpdate(ChevronAnimationWrapper oldWidget) =>
      oldWidget.chevronPosition.lastPosition != widget.chevronPosition.lastPosition ||
      oldWidget.chevronPosition.currentPosition != widget.chevronPosition.currentPosition;

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
