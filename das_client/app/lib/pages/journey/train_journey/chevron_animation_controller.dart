import 'package:app/pages/journey/train_journey/journey_position/journey_position_model.dart';
import 'package:app/util/animation.dart';
import 'package:flutter/material.dart';
import 'package:sfera/component.dart';

class ChevronAnimationController with ChangeNotifier {
  ChevronAnimationController(TickerProvider tickerProvider)
    : animationController = AnimationController(
        duration: DASAnimation.longDuration,
        vsync: tickerProvider,
      );

  final AnimationController animationController;
  Animation<double>? animation;

  JourneyPoint? currentPosition;
  JourneyPoint? lastPosition;

  void onPositionUpdate(JourneyPositionModel? journeyPosition) {
    if (journeyPosition?.currentPosition != journeyPosition?.lastPosition) {
      currentPosition = journeyPosition?.currentPosition;
      lastPosition = journeyPosition?.lastPosition;

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
