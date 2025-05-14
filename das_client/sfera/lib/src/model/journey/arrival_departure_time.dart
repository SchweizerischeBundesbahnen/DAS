import 'package:meta/meta.dart';

@sealed
@immutable
class ArrivalDepartureTime {
  const ArrivalDepartureTime({
    DateTime? operationalDepartureTime,
    DateTime? plannedDepartureTime,
    DateTime? operationalArrivalTime,
    DateTime? plannedArrivalTime,
  })  : _operationalDepartureTime = operationalDepartureTime,
        _operationalArrivalTime = operationalArrivalTime,
        _plannedArrivalTime = plannedArrivalTime,
        _plannedDepartureTime = plannedDepartureTime;

  final DateTime? _operationalDepartureTime;
  final DateTime? _operationalArrivalTime;
  final DateTime? _plannedDepartureTime;
  final DateTime? _plannedArrivalTime;

  bool get hasAnyTime =>
      operationalArrivalTime != null ||
      plannedArrivalTime != null ||
      operationalDepartureTime != null ||
      plannedDepartureTime != null;

  DateTime? get plannedDepartureTime => _isDepartureTimeCalculated ? _plannedDepartureTime : _operationalDepartureTime;

  DateTime? get operationalDepartureTime => _isDepartureTimeCalculated ? _operationalDepartureTime : null;

  DateTime? get plannedArrivalTime => _isArrivalTimeCalculated ? _plannedArrivalTime : _operationalArrivalTime;

  DateTime? get operationalArrivalTime => _isArrivalTimeCalculated ? _operationalArrivalTime : null;

  bool get _isDepartureTimeCalculated => _operationalDepartureTime != null && _plannedDepartureTime != null;

  bool get _isArrivalTimeCalculated => _operationalArrivalTime != null && _plannedArrivalTime != null;

  // > 2h before Journey - sent operational times are **planned** times and no planned times are sent separately
  // < 2h before Journey - sent operational times are **calculated** times and planned times are sent separately
  bool get hasAnyCalculatedTime => _isDepartureTimeCalculated || _isArrivalTimeCalculated;

  @override
  String toString() {
    return 'ArrivalDepartureTime('
        'operationalDepartureTime: $_operationalDepartureTime'
        ', plannedDepartureTime: $_plannedDepartureTime'
        ', operationalArrivalTime: $_operationalArrivalTime'
        ', plannedArrivalTime: $_plannedArrivalTime'
        ')';
  }
}
