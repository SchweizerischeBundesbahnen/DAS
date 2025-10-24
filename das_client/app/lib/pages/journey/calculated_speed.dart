import 'package:sfera/component.dart';

class CalculatedSpeed {
  CalculatedSpeed({
    required this.speed,
    this.isPrevious = false,
    this.isSameAsPrevious = false,
    this.isReducedDueToLineSpeed = false,
  });

  factory CalculatedSpeed.none() {
    return CalculatedSpeed(
      speed: null,
    );
  }

  final SingleSpeed? speed;
  final bool isPrevious;
  final bool isSameAsPrevious;
  final bool isReducedDueToLineSpeed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculatedSpeed &&
          runtimeType == other.runtimeType &&
          speed == other.speed &&
          isPrevious == other.isPrevious &&
          isSameAsPrevious == other.isSameAsPrevious &&
          isReducedDueToLineSpeed == other.isReducedDueToLineSpeed;

  @override
  int get hashCode => Object.hash(speed, isPrevious, isSameAsPrevious, isReducedDueToLineSpeed);

  @override
  String toString() {
    return 'CalculatedSpeed{speed: $speed, isPrevious: $isPrevious, isSameAsPrevious: $isSameAsPrevious, isReducedDueToLineSpeed: $isReducedDueToLineSpeed}';
  }
}
