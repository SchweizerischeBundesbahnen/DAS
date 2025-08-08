import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class ChevronAnimationController with ChangeNotifier {
  ChevronAnimationController(this.tickerProvider)
    : animationController = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: tickerProvider,
      );

  final TickerProvider tickerProvider;
  final AnimationController animationController;
  Animation<double>? animation;

  JourneyPoint? currentPosition;
  JourneyPoint? lastPosition;

  void onJourneyUpdate(Journey journey) {
    if (journey.metadata.currentPosition != journey.metadata.lastPosition) {
      currentPosition = journey.metadata.currentPosition;
      lastPosition = journey.metadata.lastPosition;

      animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController)
        ..addListener(() => notifyListeners());
      animationController.reset();
      animationController.forward();
    }
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
