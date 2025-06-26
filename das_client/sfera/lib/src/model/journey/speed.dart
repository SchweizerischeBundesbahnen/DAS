import 'package:meta/meta.dart';

@sealed
@immutable
class Speed {
  // Accepts \d+, {\d+}, [\d+], XX, {XX}, [XX]
  static final RegExp _speedRegex = RegExp(r'^(\d+|XX)$|^\[(\d+|XX)\]$|^\{(\d+|XX)\}$');

  // Accepts \d+, XX
  static final RegExp _speedValueRegex = RegExp(r'\d+|XX');

  const Speed({
    required this.value,
    this.isSquared = false,
    this.isCircled = false,
  });

  /// Constructs a new Speed instance based on [formattedString].
  ///
  /// Throws a FormatException if the input string cannot be parsed.
  ///
  /// The formattedString is expected to be something like '50', '{60}' or '&#91;XX&#93;'
  static Speed parse(String formattedString) {
    if (!isValid(formattedString)) throw FormatException('Invalid speed: $formattedString');

    final speedValue = _speedValueRegex.stringMatch(formattedString);
    return Speed(
      value: speedValue!,
      isCircled: formattedString.contains('{'),
      isSquared: formattedString.contains('['),
    );
  }

  /// Returns true if the [formattedString] can be parsed into a Speed instance, false otherwise.
  static bool isValid(String formattedString) => _speedRegex.hasMatch(formattedString);

  /// The value of this or 'XX'.
  final String value;

  /// Normally means that speed is higher than given by signaling. Can have other meanings so this variable is named generically.
  final bool isSquared;

  /// Normally means that speed is lower than given by signaling. Can have other meanings so this variable is named generically.
  final bool isCircled;

  @override
  String toString() {
    return 'Speed(value: $value, isSquared: $isSquared, isCircled: $isCircled)';
  }
}
