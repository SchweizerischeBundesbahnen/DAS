import 'package:app/pages/journey/journey_screen/view_model/model/chevron_position_model.dart';
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

  void onPositionUpdate(ChevronPositionModel chevronPosition) {
    if (chevronPosition.currentPosition != chevronPosition.lastPosition) {
      currentPosition = chevronPosition.currentPosition;
      lastPosition = chevronPosition.lastPosition;

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
