import 'dart:async';

import 'package:app/pages/journey/calculated_speed.dart';
import 'package:app/pages/journey/line_speed_view_model.dart';
import 'package:app/pages/journey/train_journey_view_model.dart';
import 'package:sfera/component.dart';

class CalculatedSpeedViewModel {
  CalculatedSpeedViewModel({
    required TrainJourneyViewModel trainJourneyViewModel,
    required LineSpeedViewModel lineSpeedViewModel,
  }) : _trainJourneyViewModel = trainJourneyViewModel,
       _lineSpeedViewModel = lineSpeedViewModel {
    _init();
  }

  final TrainJourneyViewModel _trainJourneyViewModel;
  final LineSpeedViewModel _lineSpeedViewModel;
  Metadata? _lastMetadata;

  StreamSubscription? _journeySubscription;

  void _init() {
    _journeySubscription = _trainJourneyViewModel.journey.listen((journey) {
      _lastMetadata = journey?.metadata;
    });
  }

  CalculatedSpeed getCalculatedSpeedForOrder(int order) {
    final metadata = _lastMetadata;
    if (metadata == null) return CalculatedSpeed.none();

    var key = order;
    var isPrevious = false;
    if (!metadata.calculatedSpeeds.containsKey(key)) {
      key = metadata.calculatedSpeeds.lastKeyBefore(order) ?? order;
      isPrevious = true;
    }
    final calculatedSpeed = metadata.calculatedSpeeds[key];

    if (calculatedSpeed == null) return CalculatedSpeed.none();

    final reducedToLineSpeedResult = _calculateReducedDueToLineSpeed(order, calculatedSpeed);
    final finalSpeed = reducedToLineSpeedResult.$2;

    final lastKey = metadata.calculatedSpeeds.lastKeyBefore(key);
    final lastCalculatedSpeed = lastKey != null ? metadata.calculatedSpeeds[lastKey] : null;
    final previousReducedToLineSpeedResult = _calculateReducedDueToLineSpeed(lastKey, lastCalculatedSpeed);
    final previousFinalSpeed = previousReducedToLineSpeedResult.$2;

    final sameAsPrevious = finalSpeed == previousFinalSpeed;

    return CalculatedSpeed(
      speed: finalSpeed,
      isPrevious: isPrevious,
      isSameAsPrevious: sameAsPrevious,
      isReducedDueToLineSpeed: reducedToLineSpeedResult.$1,
    );
  }

  (bool reducedDueToLineSpeed, SingleSpeed? speed) _calculateReducedDueToLineSpeed(
    int? order,
    SingleSpeed? calculatedSpeed,
  ) {
    if (order == null || calculatedSpeed == null) {
      return (false, calculatedSpeed);
    }

    final resolvedLineSpeed = _lineSpeedViewModel.getResolvedSpeedForOrder(order).speed;
    final reducedDueToLineSpeed = calculatedSpeed.isLargerThan(resolvedLineSpeed?.speed);
    return (reducedDueToLineSpeed, reducedDueToLineSpeed ? resolvedLineSpeed!.speed as SingleSpeed : calculatedSpeed);
  }

  void dispose() {
    _journeySubscription?.cancel();
    _journeySubscription = null;
  }
}

extension _SingleSpeedExtension on SingleSpeed {
  bool isLargerThan(Speed? other) {
    if (other == null) return false;
    if (other.isIllegal) return false;
    if (other is! SingleSpeed) return false;
    return int.parse(value) > int.parse(other.value);
  }
}
