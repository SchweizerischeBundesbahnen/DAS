import 'package:meta/meta.dart';

/// Departure and arrival times are private since the logic of figuring out whether a time is planned or
/// operational from the ambiguous times are handled in here
@sealed
@immutable
class const ArrivalDepartureTime({
  final DateTime? _ambiguousDepartureTime,
  final DateTime? _plannedDepartureTime,
  final DateTime? _ambiguousArrivalTime,
  final DateTime? _plannedArrivalTime,
  final DateTime? plannedReleasedTime,
  final bool fixedPointRelevance = false,
}) {
  bool get hasAnyTime =>
      operationalArrivalTime != null ||
      plannedArrivalTime != null ||
      operationalDepartureTime != null ||
      plannedDepartureTime != null ||
      plannedReleasedTime != null;

  DateTime? get plannedDepartureTime =>
      _isDepartureTimeCalculated ? _plannedDepartureTime : _ambiguousDepartureTime ?? _plannedDepartureTime;

  DateTime? get operationalDepartureTime => _isDepartureTimeCalculated ? _ambiguousDepartureTime : null;

  /// The most accurate known departure time: operational time when available, planned time otherwise.
  DateTime? get bestKnownDepartureTime => operationalDepartureTime ?? plannedDepartureTime;

  DateTime? get plannedArrivalTime =>
      _isArrivalTimeCalculated ? _plannedArrivalTime : _ambiguousArrivalTime ?? _plannedArrivalTime;

  DateTime? get operationalArrivalTime => _isArrivalTimeCalculated ? _ambiguousArrivalTime : null;

  /// The most accurate known arrival time: operational time when available, planned time otherwise.
  DateTime? get bestKnownArrivalTime => operationalArrivalTime ?? plannedArrivalTime;

  bool get _isDepartureTimeCalculated => _ambiguousDepartureTime != null && _plannedDepartureTime != null;

  bool get _isArrivalTimeCalculated => _ambiguousArrivalTime != null && _plannedArrivalTime != null;

  // > 2h before Journey - sent operational times are **planned** times and no planned times are sent separately
  // < 2h before Journey - sent operational times are **calculated** times and planned times are sent separately
  bool get hasAnyOperationalTime => _isDepartureTimeCalculated || _isArrivalTimeCalculated;

  @override
  String toString() {
    return 'ArrivalDepartureTime{'
        'operationalDepartureTime: $operationalDepartureTime, '
        'plannedDepartureTime: $plannedDepartureTime, '
        'operationalArrivalTime: $operationalArrivalTime, '
        'plannedArrivalTime: $plannedArrivalTime, '
        'plannedReleaseTime: $plannedReleasedTime'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ArrivalDepartureTime &&
          runtimeType == other.runtimeType &&
          _ambiguousDepartureTime == other._ambiguousDepartureTime &&
          _ambiguousArrivalTime == other._ambiguousArrivalTime &&
          _plannedDepartureTime == other._plannedDepartureTime &&
          _plannedArrivalTime == other._plannedArrivalTime &&
          plannedReleasedTime == other.plannedReleasedTime;

  @override
  int get hashCode =>
      _ambiguousDepartureTime.hashCode ^
      _ambiguousArrivalTime.hashCode ^
      _plannedDepartureTime.hashCode ^
      _plannedArrivalTime.hashCode ^
      plannedReleasedTime.hashCode;
}
