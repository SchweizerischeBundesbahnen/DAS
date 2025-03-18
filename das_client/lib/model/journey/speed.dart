import 'package:meta/meta.dart';

@sealed
@immutable
class Speed {
  const Speed({
    required this.speed,
    this.isSquared = false,
    this.isCircled = false,
  });

  factory Speed.from(String value) {
    if (RegExp(speedRegex).hasMatch(value)) {
      final digit = RegExp(r'\d+').stringMatch(value);
      return Speed(
        speed: int.parse(digit!),
        isCircled: value.contains('{'),
        isSquared: value.contains('['),
      );
    }

    throw ArgumentError('Invalid speed format: $value');
  }

  static const speedRegex = r'^\d+$|^\[\d+\]$|^\{\d+\}$'; // exp. 50, {60} or [70]

  final int speed;

  /// Normally means that speed is higher than given by signaling. Can have other meanings so this variable is named generically.
  final bool isSquared;

  /// Normally means that speed is lower than given by signaling. Can have other meanings so this variable is named generically.
  final bool isCircled;

  @override
  String toString() {
    return 'Speed(speed: $speed, isSquared: $isSquared, isCircled: $isCircled)';
  }
}
