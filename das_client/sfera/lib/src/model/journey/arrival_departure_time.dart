import 'package:meta/meta.dart';

@sealed
@immutable
class ArrivalDepartureTime {
  const ArrivalDepartureTime({
    DateTime? ambiguousDepartureTime,
    DateTime? plannedDepartureTime,
    DateTime? ambiguousArrivalTime,
    DateTime? plannedArrivalTime,
  }) : _ambiguousDepartureTime = ambiguousDepartureTime,
       _ambiguousArrivalTime = ambiguousArrivalTime,
       _plannedArrivalTime = plannedArrivalTime,
       _plannedDepartureTime = plannedDepartureTime;

  /// these are private since the logic of figuring out whether a time is planned or operational from the
  /// ambiguous times are handled in here
  /// TODO: Discuss whether to move to sfera model mapper
  final DateTime? _ambiguousDepartureTime;
  final DateTime? _ambiguousArrivalTime;
  final DateTime? _plannedDepartureTime;
  final DateTime? _plannedArrivalTime;

  bool get hasAnyTime =>
      operationalArrivalTime != null ||
      plannedArrivalTime != null ||
      operationalDepartureTime != null ||
      plannedDepartureTime != null;

  DateTime? get plannedDepartureTime =>
      _isDepartureTimeCalculated ? _plannedDepartureTime : _ambiguousDepartureTime ?? _plannedDepartureTime;

  DateTime? get operationalDepartureTime => _isDepartureTimeCalculated ? _ambiguousDepartureTime : null;

  DateTime? get plannedArrivalTime =>
      _isArrivalTimeCalculated ? _plannedArrivalTime : _ambiguousArrivalTime ?? _plannedArrivalTime;

  DateTime? get operationalArrivalTime => _isArrivalTimeCalculated ? _ambiguousArrivalTime : null;

  bool get _isDepartureTimeCalculated => _ambiguousDepartureTime != null && _plannedDepartureTime != null;

  bool get _isArrivalTimeCalculated => _ambiguousArrivalTime != null && _plannedArrivalTime != null;

  // > 2h before Journey - sent operational times are **planned** times and no planned times are sent separately
  // < 2h before Journey - sent operational times are **calculated** times and planned times are sent separately
  bool get hasAnyOperationalTime => _isDepartureTimeCalculated || _isArrivalTimeCalculated;

  @override
  String toString() {
    return 'ArrivalDepartureTime('
        'operationalDepartureTime: $operationalDepartureTime'
        ', plannedDepartureTime: $plannedDepartureTime'
        ', operationalArrivalTime: $operationalArrivalTime'
        ', plannedArrivalTime: $plannedArrivalTime'
        ')';
  }
}
