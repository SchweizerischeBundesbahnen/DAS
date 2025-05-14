import 'package:meta/meta.dart';

@sealed
@immutable
class ArrivalDepartureTime {
  const ArrivalDepartureTime({
    this.operationalDepartureTime,
    this.plannedDepartureTime,
    this.operationalArrivalTime,
    this.plannedArrivalTime,
  });

  final DateTime? operationalDepartureTime;
  final DateTime? operationalArrivalTime;
  final DateTime? plannedDepartureTime;
  final DateTime? plannedArrivalTime;

  bool get isDepartureTimeCalculated => operationalDepartureTime != null && plannedDepartureTime != null;

  bool get isArrivalTimeCalculated => operationalArrivalTime != null && plannedArrivalTime != null;

  // > 2h before Journey - sent operational times are **planned** times and no planned times are sent separately
  // < 2h before Journey - sent operational times are **calculated** times and planned times are sent separately
  bool get anyCalculatedTimes => isDepartureTimeCalculated || isArrivalTimeCalculated;
  
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
