import 'package:collection/collection.dart';

sealed class Speed {
  // Accepts \d+, {\d+}, [\d+], XX, {XX}, [XX]
  // and combinations with 0 or more '-' or 0 or one '/', such as 50/60-40
  static final RegExp _speedRegex = RegExp(
    r'^((\d+|XX|\[\d+\]|\{\d+\}|\[XX\]|\{XX\})(-(\d+|XX|\[\d+\]|\{\d+\}|\[XX\]|\{XX\}))*)'
    r'(\/((\d+|XX|\[\d+\]|\{\d+\}|\[XX\]|\{XX\})(-(\d+|XX|\[\d+\]|\{\d+\}|\[XX\]|\{XX\}))*)?)?$',
  );

  const Speed();

  /// Constructs a new Speed instance based on [formattedString].
  ///
  /// Throws a FormatException if the input string cannot be parsed.
  ///
  /// The formattedString is expected to be something like '50', '{60}' or '&#91;XX&#93;'
  /// or a well formatted combination of those, e.g. 'XX/40-[30]-20'.
  static Speed parse(String formattedString) {
    if (!isValid(formattedString)) throw FormatException('Invalid speed: $formattedString');

    if (IncomingOutgoingSpeed._hasMatch(formattedString)) return IncomingOutgoingSpeed._parse(formattedString);
    if (GraduatedSpeed._hasMatch(formattedString)) return GraduatedSpeed._parse(formattedString);
    return SingleSpeed._parse(formattedString);
  }

  /// Returns true if the [formattedString] can be parsed into a Speed instance, false otherwise.
  static bool isValid(String formattedString) => _speedRegex.hasMatch(formattedString);
}

/// A speed comprised of either [SingleSpeed] or [GraduatedSpeed] values, combined by a single '/'.
class IncomingOutgoingSpeed extends Speed {
  static bool _hasMatch(String formattedString) => formattedString.contains('/');

  const IncomingOutgoingSpeed({required this.incoming, required this.outgoing});

  final Speed incoming;
  final Speed outgoing;

  static IncomingOutgoingSpeed _parse(String formattedString) {
    final speedParts = formattedString.split('/');
    final (inStr, outStr) = (speedParts[0], speedParts[1]);

    return IncomingOutgoingSpeed(incoming: Speed.parse(inStr), outgoing: Speed.parse(outStr));
  }

  @override
  String toString() {
    return 'IncomingOutgoingSpeed(incoming: $incoming, outgoing: $outgoing)';
  }

  @override
  int get hashCode => Object.hash(incoming, outgoing);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IncomingOutgoingSpeed && outgoing == other.outgoing && incoming == other.incoming);
}

/// A speed comprised of multiple [SingleSpeed] values, combined by '-'.
class GraduatedSpeed extends Speed {
  static bool _hasMatch(String formattedString) => formattedString.contains('-');

  const GraduatedSpeed({required this.speeds});

  final List<SingleSpeed> speeds;

  static GraduatedSpeed _parse(String formattedString) =>
      GraduatedSpeed(speeds: formattedString.split('-').map(SingleSpeed._parse).toList());

  @override
  String toString() {
    return 'GraduatedSpeed(speeds: $speeds)';
  }

  @override
  int get hashCode => speeds.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GraduatedSpeed && ListEquality().equals(speeds, other.speeds));
}

class SingleSpeed extends Speed {
  // Accepts \d+, XX
  static final RegExp _speedValueRegex = RegExp(r'\d+|XX');

  const SingleSpeed({
    required this.value,
    this.isSquared = false,
    this.isCircled = false,
  });

  /// Constructs a new Speed instance based on [formattedString].
  ///
  /// Throws a FormatException if the input string cannot be parsed.
  ///
  /// The formattedString is expected to be something like '50', '{60}' or '&#91;XX&#93;'
  static SingleSpeed _parse(String formattedString) {
    final speedValue = _speedValueRegex.stringMatch(formattedString);
    return SingleSpeed(
      value: speedValue!,
      isCircled: formattedString.contains('{'),
      isSquared: formattedString.contains('['),
    );
  }

  /// The value of this or 'XX'.
  final String value;

  /// Normally means that speed is higher than given by signaling. Can have other meanings so this variable is named generically.
  final bool isSquared;

  /// Normally means that speed is lower than given by signaling. Can have other meanings so this variable is named generically.
  final bool isCircled;

  @override
  String toString() {
    return 'SingleSpeed(value: $value, isSquared: $isSquared, isCircled: $isCircled)';
  }

  @override
  int get hashCode => Object.hash(value, isSquared, isCircled);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SingleSpeed && value == other.value && isSquared == other.isSquared && isCircled == other.isCircled);
}
