import 'package:sfera/component.dart';

class CalculatedSpeed {
  CalculatedSpeed({
    required this.speed,
    this.sameAsPrevious = false,
    this.reducedDueToLineSpeed = false,
  });

  factory CalculatedSpeed.none() {
    return CalculatedSpeed(
      speed: null,
    );
  }

  final SingleSpeed? speed;
  final bool sameAsPrevious;
  final bool reducedDueToLineSpeed;
}
