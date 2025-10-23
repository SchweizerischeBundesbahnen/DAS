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
  Journey? _lastJourney;

  StreamSubscription? _journeySubscription;

  void _init() {
    _journeySubscription = _trainJourneyViewModel.journey.listen((journey) {
      _lastJourney = journey;
    });
  }

  CalculatedSpeed getCalculatedSpeedForOrder(int order) {
    final metadata = _lastJourney?.metadata;
    if (metadata == null) return CalculatedSpeed.none();

    var key = order;
    if (!metadata.calculatedSpeeds.containsKey(key)) {
      key = metadata.calculatedSpeeds.lastKeyBefore(order) ?? order;
    }
    final calculatedSpeed = metadata.calculatedSpeeds[key];

    if (calculatedSpeed == null) return CalculatedSpeed.none();

    final lastKey = metadata.calculatedSpeeds.lastKeyBefore(order);
    final lastCalculatedSpeed = lastKey != null ? metadata.calculatedSpeeds[lastKey] : null;
    final sameAsPrevious = calculatedSpeed == lastCalculatedSpeed;

    final resolvedLineSpeed = _lineSpeedViewModel.getResolvedSpeedForOrder(order).speed;
    final reducedDueToLineSpeed = calculatedSpeed.isLargerThan(resolvedLineSpeed?.speed);

    return CalculatedSpeed(
      speed: reducedDueToLineSpeed ? resolvedLineSpeed!.speed as SingleSpeed : calculatedSpeed,
      isSameAsPrevious: sameAsPrevious,
      isReducedDueToLineSpeed: reducedDueToLineSpeed,
    );
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
