import 'package:sfera/component.dart';

class CalculatedSpeed {
  CalculatedSpeed({
    required this.speed,
    this.isSameAsPrevious = false,
    this.isReducedDueToLineSpeed = false,
  });

  factory CalculatedSpeed.none() {
    return CalculatedSpeed(
      speed: null,
    );
  }

  final SingleSpeed? speed;
  final bool isSameAsPrevious;
  final bool isReducedDueToLineSpeed;
}
