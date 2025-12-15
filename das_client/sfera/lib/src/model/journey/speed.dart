import 'package:collection/collection.dart';

sealed class Speed {
  // Accepts \d+, {\d+}, [\d+], XX, {XX}, [XX]
  // and combinations with 0 or more '-' or 0 or one '/', such as 50/60-40
  static final RegExp _speedRegex = RegExp(
    r'^((\d+|XX|\[\d+\]|\{\d+\}|\[XX\]|\{XX\})(-(\d+|XX|\[\d+\]|\{\d+\}|\[XX\]|\{XX\}))*)'
    r'(\/((\d+|XX|\[\d+\]|\{\d+\}|\[XX\]|\{XX\})(-(\d+|XX|\[\d+\]|\{\d+\}|\[XX\]|\{XX\}))*)?)?$',
  );

  const Speed();

  /// Constructs a new Speed instance based on [input].
  ///
  /// Throws a FormatException if the input string cannot be parsed.
  ///
  /// The formattedString is expected to be something like '50', '{60}', '-1000' or '&#91;XX&#93;'
  /// or a well formatted combination of those, e.g. 'XX/40-[30]-20'.
  /// All whitespaces are ignored.
  static Speed parse(String input) {
    final strippedString = input.whitespaceRemoved.convertedInvalidSpeed;
    if (!isValid(strippedString)) throw FormatException('Invalid speed: $input');

    if (IncomingOutgoingSpeed._hasMatch(strippedString)) return IncomingOutgoingSpeed._parse(strippedString);
    if (GraduatedSpeed._hasMatch(strippedString)) return GraduatedSpeed._parse(strippedString);
    return SingleSpeed._parse(strippedString);
  }

  /// Returns true if the [input] can be parsed into a Speed instance, false otherwise.
  static bool isValid(String input) => _speedRegex.hasMatch(input.whitespaceRemoved.convertedInvalidSpeed);

  bool get isIllegal => false;
}

/// A speed for summarized curves, it contains a [speeds] list with all the
/// speeds of the summarized curves joined by '-'.
class SummarizedCurvesSpeed extends Speed {
  const SummarizedCurvesSpeed({required this.speeds})
    : assert(speeds.length >= 2, 'SummarizedCurvesSpeed needs at least two speeds.');

  /// For one trainSeries/breakSeries: the speeds of each curve in the segment.
  final List<SingleSpeed> speeds;

  @override
  bool get isIllegal => speeds.any((s) => s.isIllegal);

  @override
  String toString() => 'SummarizedCurvesSpeed(${speeds.map((s) => s.value).join('-')})';

  @override
  int get hashCode => const ListEquality<SingleSpeed>().hash(speeds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SummarizedCurvesSpeed && const ListEquality<SingleSpeed>().equals(speeds, other.speeds);
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
  bool get isIllegal {
    return incoming.isIllegal || outgoing.isIllegal;
  }

  @override
  String toString() {
    return 'IncomingOutgoingSpeed{incoming: $incoming, outgoing: $outgoing}';
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
  bool get isIllegal => speeds.any((speed) => speed.isIllegal);

  @override
  String toString() {
    return 'GraduatedSpeed{speeds: $speeds}';
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
  /// The formattedString is expected to be something like '50', '{60}', '-1000 or '&#91;XX&#93;'
  static SingleSpeed _parse(String formattedString) {
    final speedValue = _speedValueRegex.stringMatch(formattedString);
    return SingleSpeed(
      value: speedValue!,
      isCircled: formattedString.contains('{'),
      isSquared: formattedString.contains('['),
    );
  }

  @override
  bool get isIllegal => value == 'XX';

  /// The value of this or 'XX'.
  final String value;

  /// Normally means that speed is higher than given by signaling. Can have other meanings so this variable is named generically.
  final bool isSquared;

  /// Normally means that speed is lower than given by signaling. Can have other meanings so this variable is named generically.
  final bool isCircled;

  @override
  String toString() {
    return 'SingleSpeed{value: $value, isSquared: $isSquared, isCircled: $isCircled}';
  }

  @override
  int get hashCode => Object.hash(value, isSquared, isCircled);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SingleSpeed && value == other.value && isSquared == other.isSquared && isCircled == other.isCircled);
}

extension _StringX on String {
  String get whitespaceRemoved => replaceAll(RegExp(r'\s*'), '');

  String get convertedInvalidSpeed => replaceAll('-1000', 'XX');
}
