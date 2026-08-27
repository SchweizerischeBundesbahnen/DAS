import 'package:sfera/component.dart';

class CalculatedSpeed({
  required final SingleSpeed? speed,
  final bool isPrevious = false,
  final bool isSameAsPrevious = false,
  final bool isReducedDueToLineSpeed = false,
}) {
  factory CalculatedSpeed.none() => CalculatedSpeed(speed: null);

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
