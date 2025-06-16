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
      final speedValue = RegExp(r'\d+|XX').stringMatch(value);
      return Speed(
        speed: speedValue!,
        isCircled: value.contains('{'),
        isSquared: value.contains('['),
      );
    }

    throw ArgumentError('Invalid speed format: $value');
  }

  // Accepts 50, {60}, [70], XX, {XX}, [XX]
  static const speedRegex = r'^(\d+|XX)$|^\[(\d+|XX)\]$|^\{(\d+|XX)\}$';

  final String speed;

  /// Normally means that speed is higher than given by signaling. Can have other meanings so this variable is named generically.
  final bool isSquared;

  /// Normally means that speed is lower than given by signaling. Can have other meanings so this variable is named generically.
  final bool isCircled;

  @override
  String toString() {
    return 'Speed(speed: $speed, isSquared: $isSquared, isCircled: $isCircled)';
  }
}
