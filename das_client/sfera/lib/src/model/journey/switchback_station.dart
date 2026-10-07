import 'package:sfera/component.dart';

class SwitchbackStation({
  required final ServicePoint station,
  required final ServicePoint otherStation,
  required final bool isArrival,
}) {
  bool get isDeparture => !isArrival;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SwitchbackStation &&
          runtimeType == other.runtimeType &&
          station == other.station &&
          otherStation == other.otherStation &&
          isArrival == other.isArrival;

  @override
  int get hashCode => station.hashCode ^ otherStation.hashCode ^ isArrival.hashCode;

  @override
  String toString() {
    return 'SwitchbackStation{station: $station, otherStation: $otherStation, isArrival: $isArrival}';
  }
}
