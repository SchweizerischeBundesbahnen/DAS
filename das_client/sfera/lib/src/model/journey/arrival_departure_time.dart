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
  final DateTime? plannedDepartureTime;

  final DateTime? operationalArrivalTime;
  final DateTime? plannedArrivalTime;

  @override
  String toString() {
    return 'ArrivalDepartureTime('
        'operationalDepartureTime: $operationalDepartureTime'
        ' ,plannedDepartureTime: $plannedDepartureTime'
        ' ,operationalArrivalTime: $operationalArrivalTime'
        ' ,plannedArrivalTime: $plannedArrivalTime'
        ')';
  }
}
