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
        _plannedDepartureTime = plannedDepartureTime,
        _operationalArrivalTime = operationalArrivalTime,
        _plannedArrivalTime = plannedArrivalTime;

  DateTime? get primaryDepartureTime => _operationalDepartureTime ?? _plannedDepartureTime;

  DateTime? get primaryArrivalTime => _operationalArrivalTime ?? _plannedArrivalTime;

  DateTime? get secondaryDepartureTime => _plannedDepartureTime ?? _operationalDepartureTime;

  DateTime? get secondaryArrivalTime => _plannedArrivalTime ?? _operationalArrivalTime;

  // > 2h before Journey - sent operational times are **planned** times and no planned times are sent separately
  // < 2h before Journey - sent operational times are **calculated** times and planned times are sent separately
  bool get hasCalculatedTimes =>
      (_plannedDepartureTime != null && _operationalDepartureTime != null) ||
      (_plannedArrivalTime != null && _operationalArrivalTime != null);

  final DateTime? _operationalDepartureTime;
  final DateTime? _plannedDepartureTime;

  final DateTime? _operationalArrivalTime;
  final DateTime? _plannedArrivalTime;

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
