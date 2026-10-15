import 'package:sfera/component.dart';

class SwitchbackStation({
  required final ServicePoint station,
  required final ServicePoint counterpartStation,
  required final bool isArrival,
}) {
  bool get isDeparture => !isArrival;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwitchbackStation &&
          runtimeType == other.runtimeType &&
          station == other.station &&
          counterpartStation == other.counterpartStation &&
          isArrival == other.isArrival;

  @override
  int get hashCode => station.hashCode ^ counterpartStation.hashCode ^ isArrival.hashCode;

  @override
  String toString() {
    return 'SwitchbackStation{station: $station, counterpartStation: $counterpartStation, isArrival: $isArrival}';
  }
}
