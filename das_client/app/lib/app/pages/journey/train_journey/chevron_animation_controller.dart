import 'package:app/model/journey/base_data.dart';
import 'package:app/model/journey/journey.dart';
import 'package:flutter/material.dart';

class ChevronAnimationController with ChangeNotifier {
  ChevronAnimationController(this.tickerProvider)
      : animationController = AnimationController(
          duration: const Duration(milliseconds: 500),
          vsync: tickerProvider,
        );

  final TickerProvider tickerProvider;
  final AnimationController animationController;
  Animation<double>? animation;

  BaseData? currentPosition;
  BaseData? lastPosition;

  void onJourneyUpdate(Journey journey) {
    if (journey.metadata.currentPosition != journey.metadata.lastPosition) {
      currentPosition = journey.metadata.currentPosition;
      lastPosition = journey.metadata.lastPosition;

      animation = Tween<double>(begin: 0.0, end: 1.0).animate(animationController)
        ..addListener(() {
          notifyListeners();
        });
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
