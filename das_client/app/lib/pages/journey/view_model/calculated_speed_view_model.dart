import 'package:app/pages/journey/model/calculated_speed.dart';
import 'package:app/pages/journey/view_model/journey_aware_view_model.dart';
import 'package:app/pages/journey/view_model/line_speed_view_model.dart';
import 'package:sfera/component.dart';

class CalculatedSpeedViewModel extends JourneyAwareViewModel {
  CalculatedSpeedViewModel({
    required LineSpeedViewModel lineSpeedViewModel,
    super.journeyTableViewModel,
  }) : _lineSpeedViewModel = lineSpeedViewModel;

  final LineSpeedViewModel _lineSpeedViewModel;

  CalculatedSpeed getCalculatedSpeedForOrder(int order) {
    final metadata = lastJourney?.metadata;
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

  @override
  void journeyIdentificationChanged(Journey? journey) {}
}

extension _SingleSpeedExtension on SingleSpeed {
  bool isLargerThan(Speed? other) {
    if (other == null) return false;
    if (other.isIllegal) return false;
    if (other is! SingleSpeed) return false;
    return int.parse(value) > int.parse(other.value);
  }
}
