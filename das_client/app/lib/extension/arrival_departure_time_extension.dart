import 'package:app/util/format.dart' show Format;
import 'package:sfera/component.dart';

extension ArrivalDepartureTimeX on ArrivalDepartureTime? {
  (String, String) formattedTimes({required bool showOperationalTime, required bool showTimesInBrackets}) {
    String departureTime = '';
    String arrivalTime = '';
    if (this == null) return (departureTime, arrivalTime);

    if (showOperationalTime) {
      departureTime = Format.operationalTime(this?.operationalDepartureTime);
      arrivalTime = Format.operationalTime(this?.operationalArrivalTime);
    } else {
      departureTime = Format.plannedTime(this?.plannedDepartureTime);
      arrivalTime = Format.plannedTime(this?.plannedArrivalTime);
    }

    if (showTimesInBrackets) {
      departureTime = departureTime.isNotEmpty ? '($departureTime)' : departureTime;
      arrivalTime = arrivalTime.isNotEmpty ? '($arrivalTime)' : arrivalTime;
    }

    arrivalTime = arrivalTime.isNotEmpty ? '$arrivalTime\n' : arrivalTime;

    return (departureTime, arrivalTime);
  }
}
