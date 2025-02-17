import 'package:das_client/app/pages/journey/train_journey/chevron_animation_controller.dart';
import 'package:das_client/model/journey/journey.dart';
import 'package:flutter/cupertino.dart';

class ChevronAnimationWrapper extends StatefulWidget {
  const ChevronAnimationWrapper({
    required this.child,
    required this.journey,
    super.key,
  });

  final Widget child;
  final Journey journey;

  @override
  State<ChevronAnimationWrapper> createState() => _ChevronAnimationWrapperState();

  static ChevronAnimationController? of(BuildContext? context) =>
      context?.dependOnInheritedWidgetOfExactType<_ChevronAnimationWrapper>()?.controller;
}

class _ChevronAnimationWrapperState extends State<ChevronAnimationWrapper> with TickerProviderStateMixin {
  late final ChevronAnimationController _controller;

  @override
  void initState() {
    _controller = ChevronAnimationController(this);
    _controller.onJourneyUpdate(widget.journey);
    super.initState();
  }

  @override
  void didUpdateWidget(covariant ChevronAnimationWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.journey != widget.journey) {
      _controller.onJourneyUpdate(widget.journey);
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
